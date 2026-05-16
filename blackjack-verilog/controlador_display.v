// ============================================================
// Módulo  : controlador_display
// Autor   : Claude (Assistente de IA – Anthropic)
// Data    : 18 de Abril de 2026
//
// Descrição:
//   Controla dois displays de 7 segmentos para exibir
//   o total da mão (jogador ou banca) em formato decimal.
//   Suporta valores de 0 a 31 (cobre todos os casos do jogo).
//
//   Quando o sinal 'exibir' está em 0, ambos os displays ficam
//   completamente apagados (todos segmentos desligados).
//   Isso é usado para esconder a mão da banca durante
//   o turno do jogador, conforme especificação.
//
//   Depende de: decodificador_7seg.v
//
// Entradas:
//   valor  : total da mão a exibir (6 bits, 0–63)
//   exibir : 1 = exibe o valor | 0 = apaga os displays
//
// Saídas:
//   seg_dezena  : display da dezena  (dígito das dezenas)
//   seg_unidade : display da unidade (dígito das unidades)
//
// Uso:
//   Jogador : exibir = 1'b1       (sempre visível)
//   Banca   : exibir = mostra_banca (visível só em RESULTADO)
// ============================================================

module controlador_display (
    input  wire [5:0] valor,       // Total da mão (0–31)
    input  wire       exibir,      // 1 = exibe | 0 = apaga
    output wire [6:0] seg_dezena,  // 7 segmentos do dígito das dezenas
    output wire [6:0] seg_unidade  // 7 segmentos do dígito das unidades
);

    // ── Separação decimal: dezenas e unidades ─────────────────
    // Resolve dezenas via comparação (evita divisão hardware cara)
	 wire [3:0] dezenas = (valor >= 6'd30) ? 4'd3 : 
                         (valor >= 6'd20) ? 4'd2 : 
                         (valor >= 6'd10) ? 4'd1 : 4'd0;

    // Subtração: remove a contribuição das dezenas do total
    wire [5:0] contrib_dezenas = (dezenas == 4'd3) ? 6'd30 :
                                 (dezenas == 4'd2) ? 6'd20 :
                                 (dezenas == 4'd1) ? 6'd10 : 6'd0;
											
    wire [5:0] diferenca = valor - contrib_dezenas; // Resultado: 0–9
    wire [3:0] unidades  = diferenca[3:0];          // Truncamento seguro

    // ── Decodificadores 7 segmentos ───────────────────────────
    wire [6:0] bruto_dezena, bruto_unidade;

    decodificador_7seg u_dezenas  (.digito(dezenas),  .segmentos(bruto_dezena));
    decodificador_7seg u_unidades (.digito(unidades), .segmentos(bruto_unidade));

    // ── Controle de visibilidade ──────────────────────────────
    // Quando exibir = 0, todos os segmentos ficam apagados
    assign seg_dezena  = exibir ? bruto_dezena  : 7'b0000000;
    assign seg_unidade = exibir ? bruto_unidade : 7'b0000000;

endmodule
