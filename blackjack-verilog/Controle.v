// ============================================================
// Módulo      : Controle (FSM)
// Descrição   : Máquina de Estados Finitos para o Jogo Blackjack.
//               Controla o fluxo de distribuição, turnos e
//               decisões de vitória/derrota/empate.
//
//                 1. Estado de decisão manual do Ás removido. O fluxo
//                    avança direto do HIT para o WAIT_BTN.
//                 2. Estados terminais WIN / LOSE / TIE com
//                    transição correta a partir de ST_RESULTADO.
//                 3. mostra_banca restrito apenas aos estados finais.
//
// Autor       : Gemini (Assistente de IA – Google)
// Data        : Abril de 2026
// ============================================================

module CONTROLE (
    input  wire       clk,
    input  wire       reset,
    input  wire       hit,
    input  wire       stay,
    input  wire       led_as,
    input  wire [5:0] total_jogador,
    input  wire [5:0] total_banca,
    input  wire       vitoria,
    input  wire       derrota,
    input  wire       empate,

    output reg        habilita_jogador,
    output reg        habilita_banca,
    output reg        mostra_banca,
    output reg        win,
    output reg        lose,
    output reg        tie
);
    localparam INICIO        = 4'd0,
               ST_DIST_P1    = 4'd1,
               ST_DIST_D1    = 4'd2,
               ST_DIST_P2    = 4'd3,
               ST_DIST_D2    = 4'd4,
               ST_TURNO_P    = 4'd5,
               ST_WAIT_BTN   = 4'd6,
               ST_TURNO_D    = 4'd8,
               ST_ADD_D      = 4'd9,
               ST_RESULTADO  = 4'd10,
               ST_WIN        = 4'd11,
               ST_LOSE       = 4'd12,
               ST_TIE        = 4'd13;

    reg [3:0] current_state = INICIO;
    reg [3:0] next_state;

    always @(posedge clk) begin
        if (reset) current_state <= INICIO;
        else       current_state <= next_state;
    end

    always @(*) begin
        next_state       = current_state;
        habilita_jogador = 1'b0; 
        habilita_banca   = 1'b0;
        mostra_banca     = 1'b0;
        win = 1'b0; lose = 1'b0; tie = 1'b0; 

        case (current_state)
            INICIO: next_state = ST_DIST_P1;
            ST_DIST_P1: begin habilita_jogador = 1'b1; next_state = ST_DIST_D1; end 
            ST_DIST_D1: begin habilita_banca = 1'b1;   next_state = ST_DIST_P2; end 
            ST_DIST_P2: begin habilita_jogador = 1'b1; next_state = ST_DIST_D2; end 
            ST_DIST_D2: begin habilita_banca = 1'b1;   next_state = ST_TURNO_P; end 

            ST_TURNO_P: begin
                if (total_jogador > 6'd21) 
                    next_state = ST_RESULTADO;
                else if (stay) 
                    next_state = ST_TURNO_D;
                else if (hit) begin
                    habilita_jogador = 1'b1;
                    next_state       = ST_WAIT_BTN; 
                end
            end

            ST_WAIT_BTN: begin
                if (!hit) next_state = ST_TURNO_P;
            end

            ST_TURNO_D: begin
                if (total_banca <= 6'd16) next_state = ST_ADD_D;
                else                      next_state = ST_RESULTADO;
            end

            ST_ADD_D: begin habilita_banca = 1'b1; next_state = ST_TURNO_D; end 

            ST_RESULTADO: begin
                mostra_banca = 1'b1;
                if      (vitoria) next_state = ST_WIN; 
                else if (derrota) next_state = ST_LOSE;
                else if (empate)  next_state = ST_TIE; 
            end

            ST_WIN:  begin mostra_banca = 1'b1; win = 1'b1; end 
            ST_LOSE: begin mostra_banca = 1'b1; lose = 1'b1; end 
            ST_TIE:  begin mostra_banca = 1'b1; tie = 1'b1; end 

            default: next_state = INICIO;
        endcase
    end
endmodule