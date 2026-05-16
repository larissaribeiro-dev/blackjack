// ============================================================
// Módulo      : BlackJack_StateMachine
// Descrição   : Implementa exatamente o bloco "BlackJack State
//               Machine" do diagrama de circuito da Lista 2.
//
//               Entradas e saídas são idênticas ao diagrama:
//                 Entradas : clk, reset, stay, hit, card[3:0]
//                 Saídas   : win, lose, tie, player[5:0], dealer[5:0]
//
//               Saída adicional puxar_carta: pulso de 1 ciclo
//               gerado sempre que uma carta é somada. Necessário
//               para que o blackjack_top avance o contador do baralho.
//
//
// Referência  : Claude (Assistente de IA – Anthropic)
// Data        : Abril de 2026
// ============================================================

module BlackJack_StateMachine(
    input  wire       clk,
    input  wire       reset,
    input  wire       stay,
    input  wire       hit,
    input  wire [3:0] card,        // valor já decodificado: 1–10 (Ás=1, J/Q/K=10)

    output wire       win,
    output wire       lose,
    output wire       tie,
    output wire [5:0] player,      // Total do jogador
    output wire [5:0] dealer,      // Total da banca
    output wire       puxar_carta,  // Pulso: carta foi somada → avança baralho
	 output wire       led_as
);

    // ── Sinais internos ───────────────────────────────────────
    wire h_p, h_d;        // habilita_jogador, habilita_banca
    wire m_b;             // mostra_banca
    wire w_as;            // led_as
	 assign led_as = w_as;
    wire vit, der, emp;   // vitoria, derrota, empate

    // puxar_carta é a união dos pulsos de habilitação
    assign puxar_carta = h_p | h_d;

    // ── DATAPATH ──────────────────────────────────────────────
    DATAPATH dp (
        .clk               (clk),
        .reset             (reset),
        .entrada_carta     (card),
        .habilita_jogador  (h_p),
        .habilita_banca    (h_d),
        .mostra_banca      (m_b),
        .led_as            (w_as),
        .total_jogador     (player),
        .total_banca       (dealer),
        .estouro_jogador   (),
        .estouro_banca     (),
        .vitoria           (vit),
        .derrota           (der),
        .empate            (emp)
    );

    // ── CONTROLE (FSM) ────────────────────────────────────────
    CONTROLE ctrl (
        .clk             (clk),
        .reset           (reset),
        .hit             (hit),
        .stay            (stay),
        .led_as          (w_as),
        .total_jogador   (player),
        .total_banca     (dealer),
        .vitoria         (vit),
        .derrota         (der),
        .empate          (emp),
        .habilita_jogador(h_p),
        .habilita_banca  (h_d),
        .mostra_banca    (m_b),
        .win             (win),
        .lose            (lose),
        .tie             (tie)
    );

endmodule