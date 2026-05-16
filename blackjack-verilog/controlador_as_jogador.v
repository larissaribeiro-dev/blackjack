// ============================================================
// Módulo      : controlador_as_jogador
// Descrição   : Gerencia o valor do Ás para o JOGADOR de forma automática.
//               Se (mao_atual + 11 <= 21) -> usa 11, caso contrário -> usa 1.
//               O LED acende apenas como indicativo visual de que um Ás 
//               foi processado na jogada.
//
// Autor       : Gemini (Assistente de IA – Google)
// Data        : Abril de 2026
// ============================================================

module controlador_as_jogador (
    input  wire [3:0] valor_base_carta, 
    input  wire       eh_as,            
    input  wire [5:0] mao_atual,        // Total atual do jogador para a decisão
    output wire       led_as,           
    output wire [3:0] valor_resolvido   
);
    // LED acende para indicar que um Ás foi processado
    assign led_as = eh_as;

    // Lógica automática: usa 11 se não estourar, senão usa 1
    wire usar_onze = (mao_atual + 7'd11 <= 7'd21);

    assign valor_resolvido = eh_as ? (usar_onze ? 4'd11 : 4'd1) : valor_base_carta; 

endmodule