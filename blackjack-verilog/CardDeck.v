// ============================================================
// Módulo      : CardDeck
// Descrição   : Memória ROM que simula um baralho padrão de
//               52 cartas para o jogo Blackjack.
//               Mapeia endereços (0 a 51) para os códigos
//               numéricos de cada carta (0x0 a 0xC):
//                 0x0 = Ás   | 0x1 = 2  | 0x2 = 3  | 0x3 = 4
//                 0x4 = 5    | 0x5 = 6  | 0x6 = 7  | 0x7 = 8
//                 0x8 = 9    | 0x9 = 10 | 0xA = J  | 0xB = Q
//                 0xC = Rei
//               Cada valor possui 4 naipes (4 repetições).
//               Endereços fora do intervalo 0–51 retornam 0x0.
//
// Referência  : Claude (Assistente de IA – Anthropic)
// Data        : Abril de 2026
// ============================================================

module CardDeck (
    input  wire [5:0] endereco,  // Endereço da carta (0 a 51)
    output reg  [3:0] carta_out  // Código da carta (0x0 a 0xC)
);

    // Memória para 52 cartas (4 bits cada)
    reg [3:0] memoria [0:51];

    initial begin
        // ── Ás (Código 0x0) ──────────────────────────────────
        memoria[0]  = 4'h0;  memoria[1]  = 4'h0;
        memoria[2]  = 4'h0;  memoria[3]  = 4'h0;
        // ── 2 (Código 0x1) ───────────────────────────────────
        memoria[4]  = 4'h1;  memoria[5]  = 4'h1;
        memoria[6]  = 4'h1;  memoria[7]  = 4'h1;
        // ── 3 (Código 0x2) ───────────────────────────────────
        memoria[8]  = 4'h2;  memoria[9]  = 4'h2;
        memoria[10] = 4'h2;  memoria[11] = 4'h2;
        // ── 4 (Código 0x3) ───────────────────────────────────
        memoria[12] = 4'h3;  memoria[13] = 4'h3;
        memoria[14] = 4'h3;  memoria[15] = 4'h3;
        // ── 5 (Código 0x4) ───────────────────────────────────
        memoria[16] = 4'h4;  memoria[17] = 4'h4;
        memoria[18] = 4'h4;  memoria[19] = 4'h4;
        // ── 6 (Código 0x5) ───────────────────────────────────
        memoria[20] = 4'h5;  memoria[21] = 4'h5;
        memoria[22] = 4'h5;  memoria[23] = 4'h5;
        // ── 7 (Código 0x6) ───────────────────────────────────
        memoria[24] = 4'h6;  memoria[25] = 4'h6;
        memoria[26] = 4'h6;  memoria[27] = 4'h6;
        // ── 8 (Código 0x7) ───────────────────────────────────
        memoria[28] = 4'h7;  memoria[29] = 4'h7;
        memoria[30] = 4'h7;  memoria[31] = 4'h7;
        // ── 9 (Código 0x8) ───────────────────────────────────
        memoria[32] = 4'h8;  memoria[33] = 4'h8;
        memoria[34] = 4'h8;  memoria[35] = 4'h8;
        // ── 10 (Código 0x9) ──────────────────────────────────
        memoria[36] = 4'h9;  memoria[37] = 4'h9;
        memoria[38] = 4'h9;  memoria[39] = 4'h9;
        // ── Valete / J (Código 0xA) ───────────────────────────
        memoria[40] = 4'hA;  memoria[41] = 4'hA;
        memoria[42] = 4'hA;  memoria[43] = 4'hA;
        // ── Dama / Q (Código 0xB) ─────────────────────────────
        memoria[44] = 4'hB;  memoria[45] = 4'hB;
        memoria[46] = 4'hB;  memoria[47] = 4'hB;
        // ── Rei / K (Código 0xC) ──────────────────────────────
        memoria[48] = 4'hC;  memoria[49] = 4'hC;
        memoria[50] = 4'hC;  memoria[51] = 4'hC;
    end

    always @(*) begin
        // Proteção: endereço fora do intervalo retorna 0x0 (Ás)
        if (endereco <= 6'd51)
            carta_out = memoria[endereco];
        else
            carta_out = 4'h0;
    end

endmodule
