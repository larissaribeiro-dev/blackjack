// ============================================================
// Módulo      : blackjack_tb (Testbench)
// Descrição   : Simulação funcional completa do jogo Blackjack.
//               Cobre todos os estados da FSM atualizada:
//
//               INICIO → ST_DIST_P1 → ST_DIST_D1 → ST_DIST_P2
//               → ST_DIST_D2 → ST_TURNO_P
//                  ├─(hit=1)─→ ST_WAIT_BTN ─(hit=0)─→ ST_TURNO_P
//                  ├─(stay=1)─→ ST_TURNO_D
//                  │               ├─(total_banca≤16)─→ ST_ADD_D ─→ ST_TURNO_D
//                  │               └─(total_banca>16)─→ ST_RESULTADO
//                  └─(total_jogador>21)─→ ST_RESULTADO
//                                              ├─→ ST_WIN
//                                              ├─→ ST_LOSE
//                                              └─→ ST_TIE
//
// Mapeamento de hardware (DE10-Lite):
//   KEY[0] = HIT   (ativo baixo — pulso em 0 por ≥ 21ms)
//   KEY[1] = RESET (ativo baixo — pulso em 0 por ≥ 21ms)
//   SW[9]  = STAY  (ativo alto, nível)
//   SW[0]  = não utilizado (lógica do Ás é automática)
//   LEDR[0] = WIN  | LEDR[1] = LOSE | LEDR[2] = TIE
//   LEDR[9] = LED do Ás (indica que o Ás foi contado como 11)
//
// Nota sobre debouncer:
//   O debouncer interno usa um contador de 20 bits (20'hFFFFF =
//   1.048.575 ciclos a 50 MHz ≈ 21 ms). Cada acionamento de
//   botão exige que KEY seja mantido estável por DEBOUNCE_CYCLES
//   ciclos, tanto ao pressionar quanto ao soltar.
//
// Hierarquia interna (para adicionar sinais no ModelSim):
//   dut.bj.ctrl.current_state  ← estado atual da FSM
//   dut.bj.player              ← total do jogador (6 bits)
//   dut.bj.dealer              ← total da banca   (6 bits)
//   dut.bj.dp.total_jogador    ← equivalente via DATAPATH
//   dut.bj.dp.total_banca      ← equivalente via DATAPATH
//   (instância BlackJack_StateMachine = bj, dentro de blackjack_top)
//
// Autores     : Claude AI — Anthropic
// Data        : Abril de 2026
// ============================================================

`timescale 1ns/1ps

module blackjack_tb();

    // ─────────────────────────────────────────────────────────
    // Parâmetros de tempo
    // ─────────────────────────────────────────────────────────
    // Margem de +10 ciclos sobre o limiar do debouncer (20'hFFFFF)
    localparam DEBOUNCE_CYCLES = 20'hFFFFF + 10; // 1.048.585 ciclos
    localparam CLK_HALF        = 10;              // meio período = 10 ns → 50 MHz
    localparam CLK_PERIOD      = CLK_HALF * 2;   // período = 20 ns
    // Tempo total de debounce em nanosegundos
    localparam DEBOUNCE_NS     = DEBOUNCE_CYCLES * CLK_PERIOD; // ≈ 20.971.700 ns

    // ─────────────────────────────────────────────────────────
    // Sinais do DUT
    // ─────────────────────────────────────────────────────────
    reg        clk;
    reg  [1:0] key; // Repouso = 2'b11 (pull-up), ativo = 0
    reg  [9:0] sw;
    wire [9:0] ledr;
    wire [6:0] h0, h1, h2, h3;

    // ─────────────────────────────────────────────────────────
    // DUT — Design Under Test
    // ─────────────────────────────────────────────────────────
    blackjack_top dut (
        .MAX10_CLK1_50(clk),
        .KEY(key),
        .SW(sw),
        .LEDR(ledr),
        .HEX0(h0), .HEX1(h1), .HEX2(h2), .HEX3(h3)
    );

    // ─────────────────────────────────────────────────────────
    // Gerador de clock — 50 MHz
    // ─────────────────────────────────────────────────────────
    initial clk = 0;
    always #(CLK_HALF) clk = ~clk;

    // ─────────────────────────────────────────────────────────
    // Monitor contínuo — exibe mudanças nos LEDs de resultado
    // Para formas de onda no ModelSim, adicione também:
    //   dut.bj.ctrl.current_state, dut.bj.player, dut.bj.dealer
    // ─────────────────────────────────────────────────────────
    initial begin
        $monitor("[%0t ns]  WIN=%b  LOSE=%b  TIE=%b  AS_LED=%b",
                 $time, ledr[0], ledr[1], ledr[2], ledr[9]);
    end

    // =========================================================
    // TAREFAS AUXILIARES
    // =========================================================

    // ---------------------------------------------------------
    // do_reset: pressiona KEY[1] (RESET ativo-baixo) e aguarda
    //           o debouncer em ambas as bordas.
    //           Após soltar, a FSM avança automaticamente pelos
    //           4 estados de distribuição e chega a ST_TURNO_P.
    // ---------------------------------------------------------
    task do_reset;
        begin
            $display("\n[%0t ns] *** RESET — nova partida ***", $time);
            sw     = 10'b0;          // Garante STAY=0 antes do reset
            key[1] = 1'b0;           // Ativa RESET (KEY[1] ativo baixo)
            #(DEBOUNCE_NS);          // Debounce reconhece "pressionado" → rst=1
            key[1] = 1'b1;           // Solta RESET
            #(DEBOUNCE_NS);          // Debounce reconhece "solto"       → rst=0

            // FSM avança automaticamente:
            // INICIO(1) → DIST_P1(1) → DIST_D1(1) → DIST_P2(1)
            //           → DIST_D2(1) → TURNO_P
            // (cada estado dura 1 ciclo de clock)
            repeat(10) @(posedge clk);
            $display("[%0t ns]    Cartas distribuídas. Aguardando em ST_TURNO_P.", $time);
        end
    endtask

    // ---------------------------------------------------------
    // do_hit: pressiona KEY[0] (HIT ativo-baixo) e aguarda
    //         debouncer em ambas as bordas.
    //         FSM: ST_TURNO_P --(hit=1)--> ST_WAIT_BTN
    //              ST_WAIT_BTN --(hit=0)--> ST_TURNO_P
    // ---------------------------------------------------------
    task do_hit;
        begin
            $display("[%0t ns]    HIT  — jogador pede carta  (ST_TURNO_P → ST_WAIT_BTN → ST_TURNO_P)",
                     $time);
            key[0] = 1'b0;           // Pressiona HIT
            #(DEBOUNCE_NS);          // Debounce: w_hit=1 → FSM vai para ST_WAIT_BTN
            key[0] = 1'b1;           // Solta HIT
            #(DEBOUNCE_NS);          // Debounce: w_hit=0 → FSM volta a ST_TURNO_P
            repeat(5) @(posedge clk);
        end
    endtask

    // ---------------------------------------------------------
    // do_stay: ativa SW[9] (STAY nível alto).
    //          FSM: ST_TURNO_P --(stay=1)--> ST_TURNO_D
    //               ST_TURNO_D loops via ST_ADD_D até total_banca > 16,
    //               depois vai para ST_RESULTADO → ST_WIN/LOSE/TIE.
    //          Aguarda ciclos suficientes para a banca terminar.
    // ---------------------------------------------------------
    task do_stay;
        begin
            $display("[%0t ns]    STAY — jogador para  (ST_TURNO_P → ST_TURNO_D → ... → ST_RESULTADO)",
                     $time);
            sw[9] = 1'b1;            // Ativa STAY (combinacional, sem debounce)
            // A banca executa TURNO_D → ADD_D em 2 ciclos por carta.
            // Pior caso: banca parte de 0 e precisa de ~8 cartas → 16 ciclos.
            // Margem generosa de 50 ciclos.
            repeat(50) @(posedge clk);
            sw[9] = 1'b0;            // Solta STAY
            repeat(5) @(posedge clk);
        end
    endtask

    // ---------------------------------------------------------
    // exibe_resultado: lê LEDRs e imprime o estado terminal.
    // ---------------------------------------------------------
    task exibe_resultado;
        begin
            $display("  ┌─────────────────────────────────────┐");
            if      (ledr[0])
                $display("  │  RESULTADO → ST_WIN  : VITÓRIA ★   │");
            else if (ledr[1])
                $display("  │  RESULTADO → ST_LOSE : DERROTA ✗   │");
            else if (ledr[2])
                $display("  │  RESULTADO → ST_TIE  : EMPATE  =   │");
            else
                $display("  │  RESULTADO : (estado terminal não atingido)  │");
            $display("  └─────────────────────────────────────┘\n");
        end
    endtask

    // =========================================================
    // SEQUÊNCIA DE TESTES
    // =========================================================
    initial begin

        // Inicialização segura — todos em repouso
        clk = 1'b0;
        key = 2'b11;  // Pull-up: botões soltos
        sw  = 10'b0;  // Chaves em 0
        #200;

        // ─────────────────────────────────────────────────────
        // CENÁRIO 1 — STAY IMEDIATO
        // Fluxo: TURNO_P --(stay=1)--> TURNO_D --> banca joga
        //        --> RESULTADO --> WIN/LOSE/TIE
        // Objetivo: verificar distribuição automática e turno
        //           completo da banca sem intervenção do jogador.
        // ─────────────────────────────────────────────────────
        $display("\n══════════════════════════════════════════════════");
        $display("  CENÁRIO 1 — STAY IMEDIATO");
        $display("══════════════════════════════════════════════════");
        do_reset;
        do_stay;
        exibe_resultado;
        #5000;

        // ─────────────────────────────────────────────────────
        // CENÁRIO 2 — UM HIT, DEPOIS STAY
        // Fluxo: TURNO_P --(hit=1)--> WAIT_BTN
        //        --(hit=0)--> TURNO_P --(stay=1)--> TURNO_D
        //        --> RESULTADO
        // Objetivo: validar transição ST_WAIT_BTN → ST_TURNO_P
        //           e self-loop de ST_WAIT_BTN enquanto hit=1.
        // ─────────────────────────────────────────────────────
        $display("\n══════════════════════════════════════════════════");
        $display("  CENÁRIO 2 — 1 HIT + STAY");
        $display("══════════════════════════════════════════════════");
        do_reset;
        do_hit;
        do_stay;
        exibe_resultado;
        #5000;

        // ─────────────────────────────────────────────────────
        // CENÁRIO 3 — DOIS HITS, DEPOIS STAY
        // Objetivo: cobrir dois ciclos completos de
        //           TURNO_P → WAIT_BTN → TURNO_P antes do STAY.
        // ─────────────────────────────────────────────────────
        $display("\n══════════════════════════════════════════════════");
        $display("  CENÁRIO 3 — 2 HITS + STAY");
        $display("══════════════════════════════════════════════════");
        do_reset;
        do_hit;
        do_hit;
        do_stay;
        exibe_resultado;
        #5000;

        // ─────────────────────────────────────────────────────
        // CENÁRIO 4 — HITS ATÉ POSSÍVEL ESTOURO DO JOGADOR
        // Fluxo: TURNO_P → WAIT_BTN (repetido) →
        //        total_jogador > 21 → RESULTADO → LOSE
        // Objetivo: verificar a transição direta de ST_TURNO_P
        //           para ST_RESULTADO quando total_jogador > 21,
        //           e ativação de LEDR[1] (ST_LOSE).
        // Nota: com baralho aleatório, o bust não é garantido em
        //       N hits fixo. O loop para automaticamente ao LEDR
        //       de resultado acender.
        // ─────────────────────────────────────────────────────
        $display("\n══════════════════════════════════════════════════");
        $display("  CENÁRIO 4 — HITS REPETIDOS (teste de estouro)");
        $display("══════════════════════════════════════════════════");
        do_reset;
        begin : cenario4
            integer i;
            for (i = 0; i < 8; i = i + 1) begin
                // Para quando qualquer estado terminal for atingido
                if (ledr[0] || ledr[1] || ledr[2]) begin
                    $display("[%0t ns]    Estado terminal atingido em %0d hit(s).", $time, i);
                    disable cenario4;
                end
                do_hit;
            end
        end
        // Se ainda sem resultado após 8 hits, força stay
        if (!ledr[0] && !ledr[1] && !ledr[2]) begin
            $display("[%0t ns]    Sem estouro após 8 hits — forçando STAY.", $time);
            do_stay;
        end
        exibe_resultado;
        #5000;

        // ─────────────────────────────────────────────────────
        // CENÁRIO 5 — TRÊS HITS + STAY (SEMENTE DIFERENTE)
        // Objetivo: exercitar mais ciclos da FSM e garantir que
        //           a semente do LFSR produz resultado diferente.
        //           Aguarda tempo extra antes do reset para variar
        //           o cnt_seed e, portanto, o baralho gerado.
        // ─────────────────────────────────────────────────────
        $display("\n══════════════════════════════════════════════════");
        $display("  CENÁRIO 5 — 3 HITS + STAY (semente variada)");
        $display("══════════════════════════════════════════════════");
        #(DEBOUNCE_NS * 2); // Varia cnt_seed antes do reset
        do_reset;
        do_hit;
        do_hit;
        do_hit;
        if (!ledr[0] && !ledr[1] && !ledr[2])
            do_stay;
        exibe_resultado;
        #5000;

        // ─────────────────────────────────────────────────────
        // CENÁRIO 6 — STAY IMEDIATO COM SEMENTE MAIS AFASTADA
        // Objetivo: cobrir o caminho em que a banca pode estourar
        //           (ST_ADD_D → ST_TURNO_D → ST_RESULTADO → ST_WIN)
        //           com distribuição inicial diferente.
        // ─────────────────────────────────────────────────────
        $display("\n══════════════════════════════════════════════════");
        $display("  CENÁRIO 6 — STAY IMEDIATO (semente distante)");
        $display("══════════════════════════════════════════════════");
        #(DEBOUNCE_NS * 5); // Aguarda mais tempo para mudar semente
        do_reset;
        do_stay;
        exibe_resultado;
        #5000;

        // ─────────────────────────────────────────────────────
        // FIM DA SIMULAÇÃO
        // ─────────────────────────────────────────────────────
        $display("\n>>> Simulação concluída. Verifique formas de onda no ModelSim. <<<\n");
        $stop;
    end

endmodule