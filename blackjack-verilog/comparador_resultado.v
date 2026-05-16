// ============================================================
// Módulo  : comparador_resultado
// Autor   : Claude (Assistente de IA – Anthropic)
// Data    :  18 de Abril de 2026
//
// Descrição:
//   Compara as mãos do jogador e da banca ao final do jogo
//   e determina o resultado (vitória, derrota ou empate).
//   Módulo puramente combinacional (sem clock).
//
//   IMPORTANTE: As saídas (vitoria/derrota/empate) são
//   calculadas continuamente. A FSM deve lê-las APENAS quando
//   estiver no estado RESULTADO para garantir valores válidos.
//
// Prioridade das regras (conforme enunciado):
//   1. Jogador estourou (estouro_jogador = 1) → derrota
//   2. Banca estourou   (estouro_banca   = 1) → vitória
//   3. Comparação de totais:
//        total_jogador > total_banca → vitória
//        total_jogador < total_banca → derrota
//        total_jogador = total_banca → empate
//
// Entradas:
//   total_jogador   : total da mão do jogador (6 bits)
//   total_banca     : total da mão da banca   (6 bits)
//   estouro_jogador : jogador estourou 21 (de detector_estouro)
//   estouro_banca   : banca estourou 21   (de detector_estouro)
//
// Saídas (apenas uma estará ativa por vez):
//   vitoria : jogador vence
//   derrota : jogador perde
//   empate  : empate
// ============================================================


module comparador_resultado (
    input  wire [5:0] total_jogador,   // Total da mão do jogador
    input  wire [5:0] total_banca,     // Total da mão da banca
    input  wire       estouro_jogador, // 1 = jogador estourou
    input  wire       estouro_banca,   // 1 = banca estourou
    output reg        vitoria,         // Jogador vence
    output reg        derrota,         // Jogador perde
    output reg        empate           // Empate
);

    always @(*) begin
        // Valores padrão – evita latch inferido em síntese
        vitoria = 1'b0;
        derrota = 1'b0;
        empate  = 1'b0;

        if (estouro_jogador) begin
            // Regra 1: Jogador estourou → derrota imediata
            // (mesmo que a banca também tenha estourado)
            derrota = 1'b1;

        end else if (estouro_banca) begin
            // Regra 2: Banca estourou → vitória do jogador
            vitoria = 1'b1;

        end else begin
            // Regra 3: Nenhum estourou → comparação de totais
            if      (total_jogador > total_banca) vitoria = 1'b1;
            else if (total_jogador < total_banca) derrota = 1'b1;
            else                                  empate  = 1'b1;
        end
    end

endmodule
