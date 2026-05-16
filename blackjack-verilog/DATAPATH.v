// ============================================================
// Módulo      : DATAPATH
// Descrição   : Caminho de dados do Blackjack.
//               Interliga memória, registradores, lógica de Ás 
//               e comparadores de resultado.
//
//
// Autor       : Gemini (Assistente de IA – Google)
// Data        : Abril de 2026
// ============================================================

module DATAPATH (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] entrada_carta,    // valor decodificado: 1–10 (Ás=1)
    input  wire       habilita_jogador, // Vem da FSM
    input  wire       habilita_banca,   // Vem da FSM
    input  wire       mostra_banca,     // Vem da FSM

    output wire       led_as,           // Para LEDR[9]
    output wire [5:0] total_jogador,
    output wire [5:0] total_banca,
    output wire       estouro_jogador,
    output wire       estouro_banca,
    output wire       vitoria,
    output wire       derrota,
    output wire       empate
);
    // ── Sinais Internos ───────────────────────────────────────
    wire [3:0] valor_base;
    wire       eh_as;

    // ── 1. Detecção do Ás ─────────────────────────────────────
    // entrada_carta já vem decodificada; Ás é identificado pelo valor 1
    assign valor_base = entrada_carta;
    assign eh_as      = (entrada_carta == 4'd1);

    wire [3:0] valor_p_resolvido;
    wire [3:0] valor_d_resolvido;

    // ── 2. Lógica Automática do Ás (Jogador) ──────────────────
    controlador_as_jogador as_p (
        .valor_base_carta(valor_base),
        .eh_as(eh_as),
        .mao_atual(total_jogador), // Loop de realimentação para automação
        .led_as(led_as),
        .valor_resolvido(valor_p_resolvido)
    );

    // ── 3. Lógica Automática do Ás (Banca) ────────────────────
    controlador_as_banca as_d (
        .valor_base_carta(valor_base),
        .eh_as(eh_as),
        .mao_atual(total_banca),
        .valor_resolvido(valor_d_resolvido)
    );

    // ── 4. Acumuladores (Registradores de Mão) ────────────────
    registrador_mao #(6) reg_p (
        .clk(clk),
        .reset(reset),
        .habilita_soma(habilita_jogador),
        .valor_entrada(valor_p_resolvido),
        .total(total_jogador)
    );

    registrador_mao #(6) reg_d (
        .clk(clk),
        .reset(reset),
        .habilita_soma(habilita_banca),
        .valor_entrada(valor_d_resolvido),
        .total(total_banca)
    );

    // ── 5. Detecção de Estouro (Bust) ─────────────────────────
    detector_estouro det_p (.total_mao(total_jogador), .estourou(estouro_jogador));
    detector_estouro det_d (.total_mao(total_banca),   .estourou(estouro_banca));

    // ── 6. Comparação Final de Resultados ─────────────────────
    comparador_resultado comp (
        .total_jogador(total_jogador),
        .total_banca(total_banca),
        .estouro_jogador(estouro_jogador),
        .estouro_banca(estouro_banca),
        .vitoria(vitoria),
        .derrota(derrota),
        .empate(empate)
    );

endmodule