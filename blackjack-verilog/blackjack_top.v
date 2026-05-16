// ============================================================
// Módulo      : blackjack_top.v
// Descrição   : Responsável por tudo que é específico da placa:
//                 1. Inversão dos botões (ativo baixo → alto)
//                 2. Debouncers de KEY[0] e KEY[1]
//                 3. Geração de endereços do baralho (LFSR)
//                 4. Leitura da CardDeck Memory
//                 5. Instância do BlackJack_StateMachine (submodulo)
//                 6. Conversão dos totais para displays 7-seg
//                 7. Mapeamento de pinos (LEDs, HEX, SW)
//
//               Mapeamento de hardware (DE10-Lite):
//                 KEY[0]    = HIT     (ativo baixo)
//                 KEY[1]    = RESET   (ativo baixo)
//                 SW[9]     = STAY    (ativo alto)
//                 LEDR[0]   = WIN
//                 LEDR[1]   = LOSE
//                 LEDR[2]   = TIE
//                 LEDR[8:3] = apagados
//                 LEDR[9]   = led de debug do ás 
//                 HEX1/HEX0 = total do jogador (dezena/unidade)
//                 HEX3/HEX2 = total da banca   (dezena/unidade)
//
// Referência  : Claude (Assistente de IA – Anthropic)
// Data        : Abril de 2026
// ============================================================

module blackjack_top (
    input  wire       MAX10_CLK1_50,
    input  wire [1:0] KEY,
    input  wire [9:0] SW,
    output wire [9:0] LEDR,
    output wire [6:0] HEX0, HEX1, HEX2, HEX3
);

    // ── Clock ─────────────────────────────────────────────────
    wire clk = MAX10_CLK1_50;

    // ── 1. Inversão dos botões (ativo baixo → ativo alto) ─────
    wire rst_raw = ~KEY[1];
    wire hit_raw = ~KEY[0];

    // ── 2. Debouncers ─────────────────────────────────────────
    wire rst, w_hit;

    debouncer db_rst (
        .clk    (clk),
        .btn_in (rst_raw),
        .btn_out(rst)
    );

    debouncer db_hit (
        .clk    (clk),
        .btn_in (hit_raw),
        .btn_out(w_hit)
    );

    // ── Sinais de interconexão ─────────────────────────────────
    wire [5:0] addr;
    wire [3:0] card_raw;      // código bruto da CardDeck (0–12)
    wire [3:0] card_val;      // valor decodificado (1–10)
    wire       win, lose, tie;
    wire [5:0] player, dealer;
    wire       puxar_carta;   // pulso vindo do submodulo
    wire       as_debug;

    // ── 3. Contador do Baralho (LFSR) ─────────────────────────
    contador_baralho croupier (
        .clk        (clk),
        .reset      (rst),
        .puxar_carta(puxar_carta),
        .endereco   (addr)
    );

    // ── 4. CardDeck Memory ────────────────────────────────────
    CardDeck deck (
        .endereco (addr),
        .carta_out(card_raw)
    );

    // ── 4b. Decodificador de Carta ────────────────────────────
    // Converte código bruto → valor do jogo (1–10) antes de
    // entrar na BlackJack_StateMachine
    decodificador_carta dec_c (
        .entrada_carta(card_raw),
        .valor_carta  (card_val),
        .eh_as        ()           // não usado aqui; DATAPATH detecta por card_val==1
    );

    // ── 5. BlackJack State Machine (Submodulo) ────────────────
    // Recebe o valor já decodificado (1–10)
    BlackJack_StateMachine bj (
        .clk        (clk),
        .reset      (rst),
        .stay       (SW[9]),
        .hit        (w_hit),
        .card       (card_val),
        .win        (win),
        .lose       (lose),
        .tie        (tie),
        .player     (player),
        .dealer     (dealer),
        .puxar_carta(puxar_carta),
		  .led_as     (as_debug)
    );

    // ── 6. Decodificadores 7-segmentos ────────────────────────
    wire [6:0] s_p_d, s_p_u, s_d_d, s_d_u;
    wire mostra_banca = win | lose | tie;

    controlador_display disp_p (
        .valor      (player),
        .exibir     (1'b1),
        .seg_dezena (s_p_d),
        .seg_unidade(s_p_u)
    );

    controlador_display disp_d (
        .valor      (dealer),
        .exibir     (mostra_banca),
        .seg_dezena (s_d_d),
        .seg_unidade(s_d_u)
    );

    // ── 7. Mapeamento de pinos ────────────────────────────────
    // Ânodo comum (DE10-Lite): inverter bits dos segmentos
    assign HEX0 = ~s_p_u;
    assign HEX1 = ~s_p_d;
    assign HEX2 = ~s_d_u;
    assign HEX3 = ~s_d_d;

    assign LEDR[0]   = win;
    assign LEDR[1]   = lose;
    assign LEDR[2]   = tie;
    assign LEDR[8:3] = 6'b0;
    assign LEDR[9]   = as_debug;

endmodule