// ============================================================
// Módulo  : detector_estouro
// Autor   : Claude (Assistente de IA – Anthropic)
// Data    : 18 de Abril de 2026
//
// Descrição:
//   Detecta se a mão de um jogador ou da banca ultrapassou
//   o limite de 21 ("bust" / estouro).
//   Módulo puramente combinacional (sem clock).
//
//   Instanciar separadamente para o jogador e para a banca.
//
// Entrada:
//   total_mao : total atual da mão (6 bits, 0–63)
//
// Saída:
//   estourou  : 1 quando total_mao > 21 (estouro)
//               0 quando total_mao <= 21 (ainda no jogo)
// ============================================================
module detector_estouro (
    input  wire [5:0] total_mao, // Total atual da mão
    output wire       estourou   // 1 = estourou 21
);

    assign estourou = (total_mao > 6'd21);

endmodule
