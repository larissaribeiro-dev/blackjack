// ============================================================
// Módulo  : controlador_as_banca
// Autor   : Claude (Assistente de IA – Anthropic)
// Data    : 18 de Abril de 2026
//
// Descrição:
//   Gerencia o valor do Ás para a BANCA de forma automática.
//
//   Conforme especificação:
//     - NÃO acende LED (o LED é apenas para o jogador).
//     - A banca faz a mesma escolha (1 ou 11) de forma
//       automática baseada no total atual da sua mão:
//         * Se (mao_atual + 11 <= 21) → usa 11
//         * Caso contrário            → usa 1
//
//   Para cartas que não são Ás, o valor base de
//   decodificador_carta é passado diretamente sem alteração.
//
//   Módulo puramente combinacional (sem clock).
//
// Nota sobre soft-17:
//   Conforme o enunciado, a situação soft-17 (Ás + 6 = 17
//   "mole") é ignorada. A banca trata o valor da mão apenas
//   numericamente para decidir continuar (≤16) ou parar (≥17).
//
// Entradas:
//   valor_base_carta : valor base da carta (decodificador_carta)
//   eh_as            : 1 se a carta atual é Ás
//   mao_atual        : total atual da mão da banca (6 bits)
//
// Saídas:
//   valor_resolvido  : valor final a somar na mão da banca
// ============================================================

module controlador_as_banca (
    input  wire [3:0] valor_base_carta, // Valor base (decodificador_carta)
    input  wire       eh_as,            // 1 se a carta atual é Ás
    input  wire [5:0] mao_atual,        // Total atual da mão da banca
    output wire [3:0] valor_resolvido   // Valor final a somar na mão
);

    // Banca usa 11 se não estourar 21 com esse valor;
    // caso contrário, usa 1.
    // Comparação com 7 bits evita overflow na soma intermediária.
    wire usar_onze = (mao_atual + 7'd11 <= 7'd21);

    assign valor_resolvido = eh_as ? (usar_onze ? 4'd11 : 4'd1) : valor_base_carta;

endmodule
