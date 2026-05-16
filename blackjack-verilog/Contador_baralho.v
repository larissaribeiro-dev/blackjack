// ============================================================
// Módulo      : contador_baralho  (LFSR sem viés)
// Descrição   : LFSR de 6 bits que pula automaticamente os
//               estados 53–63, eliminando o viés nos endereços
//               0–10 da CardDeck. Garante que cada endereço
//               0–51 seja visitado exatamente 1× por ciclo.
//
//
// LFSR        : 6 bits, polinômio x^6 + x + 1
//               Dos 63 estados, 11 são inválidos (53–63).
//               A análise da sequência completa mostra que
//               o máximo de estados inválidos consecutivos
//               é 5 (posições 5–9 do ciclo: 63,62,61,58,53).
//               Por isso o unrolling é feito em 5 passos —
//               suficiente para sempre encontrar um estado
//               válido (≤52) no mesmo ciclo de clock.
//
// Resultado   : 52 endereços distintos, sem repetição,
//               sem viés — equivalente a um baralho real.
//
// Referência  : Claude (Assistente de IA – Anthropic)
// Data        : Abril de 2026
// ============================================================

module contador_baralho (
    input  wire       clk,
    input  wire       reset,
    input  wire       puxar_carta,
    output reg  [5:0] endereco
);

    // ── Contador de semente (entropia humana no reset) ────────
    reg [5:0] cnt_seed = 6'd1;
    always @(posedge clk) begin
        if (cnt_seed == 6'd0 || cnt_seed >= 6'd63)
            cnt_seed <= 6'd1;
        else
            cnt_seed <= cnt_seed + 6'd1;
    end

    // ── Registrador do LFSR ───────────────────────────────────
    reg [5:0] lfsr = 6'd1;

    // ── Função de avanço do LFSR (x^6 + x + 1) ───────────────
    // Usada para unrolling combinacional
    function [5:0] avanca;
        input [5:0] s;
        begin
            avanca = {s[4:0], s[5] ^ s[0]};
        end
    endfunction

    // ── Unrolling de até 5 passos para pular estados 53–63 ───
    // A análise do ciclo completo garante que após no máximo
    // 5 avanços consecutivos sempre há um estado válido (≤52).
    wire [5:0] s1 = avanca(lfsr);
    wire [5:0] s2 = avanca(s1);
    wire [5:0] s3 = avanca(s2);
    wire [5:0] s4 = avanca(s3);
    wire [5:0] s5 = avanca(s4);

    // Seleciona o primeiro estado válido encontrado
    wire [5:0] prox_lfsr =
        (s1 <= 6'd52) ? s1 :
        (s2 <= 6'd52) ? s2 :
        (s3 <= 6'd52) ? s3 :
        (s4 <= 6'd52) ? s4 :
                        s5;   // s5 é sempre ≤52 (garantido pela análise)

    // Mapeamento direto: estado 1–52 → endereço 0–51 (sem viés)
    wire [5:0] prox_endereco = prox_lfsr - 6'd1;

    // ── Lógica sequencial ─────────────────────────────────────
    always @(posedge clk) begin
        if (reset) begin
            // Semente capturada no momento em que o jogador
            // solta o reset — diferente a cada partida
            lfsr     <= cnt_seed;
            endereco <= (cnt_seed <= 6'd52) ? (cnt_seed - 6'd1)
                                            : 6'd0;
        end else if (puxar_carta) begin
            lfsr     <= prox_lfsr;
            endereco <= prox_endereco;
        end
    end

endmodule