// ============================================================
// Módulo  : registrador_mao
// Autor   : Claude (Assistente de IA – Anthropic)
// Data    : 18 de Abril de 2026
//
// Descrição:
//   Registrador sequencial que acumula o total da mão
//   de um jogador ou da banca.
//
//   A adição ocorre na borda de subida do CLK quando
//   habilita_soma está ativo (pulso de 1 ciclo de clock).
//   O reset é SÍNCRONO, conforme especificação do projeto.
//
//   Instanciar separadamente para o jogador e para a banca.
//
// Parâmetro:
//   LARGURA : largura do acumulador em bits.
//             Padrão = 6 bits (suporta valores 0–63).
//             Com mão máxima de 21, 6 bits é mais que suficiente
//             mesmo em condições de estouro (ex: 21 + 10 = 31).
//
// Entradas:
//   clk          : clock do sistema (borda de subida)
//   reset        : reset síncrono ativo alto → zera o total
//   habilita_soma: pulso de 1 ciclo → soma valor_entrada ao total
//   valor_entrada : valor a somar (1–11, 4 bits)
//
// Saída:
//   total        : total acumulado da mão (LARGURA bits)
// ============================================================
module registrador_mao #(
    parameter LARGURA = 6
)(
    input  wire               clk,           // Clock do sistema
    input  wire               reset,         // Reset síncrono ativo alto
    input  wire               habilita_soma, // Habilita adição (pulso de 1 ciclo)
    input  wire [3:0]         valor_entrada, // Valor da carta a somar (1–11)
    output reg  [LARGURA-1:0] total          // Total acumulado da mão
);

    always @(posedge clk) begin
        if (reset) begin
            // Reset síncrono: zera o total independente de habilita_soma
            total <= {LARGURA{1'b0}};
        end else if (habilita_soma) begin
            // Adiciona o valor da carta com extensão de zeros à esquerda
            total <= total + {{(LARGURA-4){1'b0}}, valor_entrada};
        end
        // Quando reset=0 e habilita_soma=0: total mantém valor
    end

endmodule
