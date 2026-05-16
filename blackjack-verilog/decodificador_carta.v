// ============================================================
// Módulo  : decodificador_carta
// Autor   : Claude (Assistente de IA – Anthropic)
// Data    : 18 de Abril de 2026
//
// Descrição:
//   Decodifica o código de 4 bits da carta (saído da
//   CardDeck Memory) para o valor numérico usado no jogo
//   e sinaliza quando a carta é um Ás.
//   Módulo puramente combinacional (sem clock).
//
// Codificação da entrada CARTA[3:0]:
//   4'h0 = Ás  | 4'h1 = 2  | 4'h2 = 3  | 4'h3 = 4
//   4'h4 = 5   | 4'h5 = 6  | 4'h6 = 7  | 4'h7 = 8
//   4'h8 = 9   | 4'h9 = 10 | 4'hA = J  | 4'hB = Q
//   4'hC = K   | default   = inválido (valor 0)
//
// Saídas:
//   valor_carta : valor base 1–10.
//                 Para o Ás, retorna 1 como padrão; o valor
//                 definitivo (1 ou 11) é resolvido pelos
//                 módulos controlador_as_jogador /
//                 controlador_as_banca.
//   eh_as       : 1 quando a carta for um Ás.
// ============================================================

module decodificador_carta (
    input  wire [3:0] entrada_carta, // Código da carta (CardDeck Memory)
    output reg  [3:0] valor_carta,   // Valor base: 1-10 (Ás = 1 por padrão)
    output reg        eh_as          // Alto quando a carta for um Ás
);

    always @(*) begin
        // Valores padrão – evita latch inferido em síntese
        valor_carta = 4'd0;
        eh_as       = 1'b0;

        case (entrada_carta)
            4'h0: begin valor_carta = 4'd1;  eh_as = 1'b1; end // Ás
            4'h1:       valor_carta = 4'd2;                     // 2
            4'h2:       valor_carta = 4'd3;                     // 3
            4'h3:       valor_carta = 4'd4;                     // 4
            4'h4:       valor_carta = 4'd5;                     // 5
            4'h5:       valor_carta = 4'd6;                     // 6
            4'h6:       valor_carta = 4'd7;                     // 7
            4'h7:       valor_carta = 4'd8;                     // 8
            4'h8:       valor_carta = 4'd9;                     // 9
            4'h9:       valor_carta = 4'd10;                    // 10
            4'hA:       valor_carta = 4'd10;                    // J  = 10
            4'hB:       valor_carta = 4'd10;                    // Q  = 10
            4'hC:       valor_carta = 4'd10;                    // K  = 10
            default:    valor_carta = 4'd0;                     // Inválido
        endcase
    end

endmodule
