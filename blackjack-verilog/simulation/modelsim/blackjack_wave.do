## ============================================================
## ModelSim Wave Script — Blackjack (hierarquia atualizada)
##
## Hierarquia após refatoração:
##   blackjack_tb                    (testbench)
##   └─ dut  : blackjack_top
##      ├─ bj : BlackJack_StateMachine
##      │   ├─ ctrl : CONTROLE  (FSM)
##      │   └─ dp   : DATAPATH
##      ├─ db_rst : debouncer
##      ├─ db_hit : debouncer
##      ├─ croupier : contador_baralho
##      └─ deck : CardDeck
##
## Diferença em relação ao script anterior:
##   ANTES: /blackjack_tb/dut/ctrl/...  e  /blackjack_tb/dut/dp/...
##   AGORA: /blackjack_tb/dut/bj/ctrl/... e /blackjack_tb/dut/bj/dp/...
##
## Como usar:
##   1. Compile todos os .v no ModelSim
##   2. Simule: vsim blackjack_tb
##   3. No console: do blackjack_wave.do
## ============================================================

onerror {resume}

## ── Radix personalizado: exibe current_state pelo nome do estado ──
radix define estados_blackjack {
    "4'd0"  "INICIO",
    "4'd1"  "ST_DIST_P1",
    "4'd2"  "ST_DIST_D1",
    "4'd3"  "ST_DIST_P2",
    "4'd4"  "ST_DIST_D2",
    "4'd5"  "ST_TURNO_P",
    "4'd6"  "ST_WAIT_BTN",
    "4'd8"  "ST_TURNO_D",
    "4'd9"  "ST_ADD_D",
    "4'd10" "ST_RESULTADO",
    "4'd11" "ST_WIN",
    "4'd12" "ST_LOSE",
    "4'd13" "ST_TIE",
    -default hexadecimal
}

quietly WaveActivateNextPane {} 0

## ── Clock ─────────────────────────────────────────────────────────
add wave -noupdate -height 42 \
    /blackjack_tb/dut/bj/dp/clk

## ── Controles do usuário ──────────────────────────────────────────
## KEY[1] = entrada física (ativo baixo) — para ver o pulso bruto
add wave -noupdate -height 42 \
    {/blackjack_tb/dut/KEY[1]}

## rst = sinal após debouncer (ativo alto) — o que a FSM enxerga
add wave -noupdate -height 42 \
    /blackjack_tb/dut/rst

## hit e stay já filtrados pelo debouncer, chegam na FSM
add wave -noupdate -height 42 \
    /blackjack_tb/dut/bj/ctrl/hit

add wave -noupdate -height 42 \
    /blackjack_tb/dut/bj/ctrl/stay

## ── Estado atual da FSM (exibido pelo nome via radix) ─────────────
add wave -noupdate -height 42 \
    -radix estados_blackjack \
    -childformat {
        {{/blackjack_tb/dut/bj/ctrl/current_state[3]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/current_state[2]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/current_state[1]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/current_state[0]} -radix unsigned}
    } \
    -radixshowbase 0 \
    -subitemconfig {
        {/blackjack_tb/dut/bj/ctrl/current_state[3]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/current_state[2]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/current_state[1]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/current_state[0]} {-height 15 -radix unsigned}
    } \
    /blackjack_tb/dut/bj/ctrl/current_state

## ── Totais (pontuações) — exibidos em decimal unsigned ────────────
add wave -noupdate -height 42 \
    -radix unsigned \
    /blackjack_tb/dut/bj/ctrl/total_jogador

add wave -noupdate -height 42 \
    -radix unsigned \
    -childformat {
        {{/blackjack_tb/dut/bj/ctrl/total_banca[5]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/total_banca[4]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/total_banca[3]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/total_banca[2]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/total_banca[1]} -radix unsigned}
        {{/blackjack_tb/dut/bj/ctrl/total_banca[0]} -radix unsigned}
    } \
    -subitemconfig {
        {/blackjack_tb/dut/bj/ctrl/total_banca[5]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/total_banca[4]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/total_banca[3]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/total_banca[2]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/total_banca[1]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/ctrl/total_banca[0]} {-height 15 -radix unsigned}
    } \
    /blackjack_tb/dut/bj/ctrl/total_banca

## ── Resultados (LEDs) ─────────────────────────────────────────────
add wave -noupdate -height 42 \
    /blackjack_tb/dut/bj/ctrl/win

add wave -noupdate -height 42 \
    /blackjack_tb/dut/bj/ctrl/lose

add wave -noupdate -height 42 \
    /blackjack_tb/dut/bj/ctrl/tie

## ── Carta atual (valor decodificado, 1–10) ───────────────────────
add wave -noupdate -height 42 \
    -radix unsigned \
    -childformat {
        {{/blackjack_tb/dut/bj/dp/entrada_carta[3]} -radix unsigned}
        {{/blackjack_tb/dut/bj/dp/entrada_carta[2]} -radix unsigned}
        {{/blackjack_tb/dut/bj/dp/entrada_carta[1]} -radix unsigned}
        {{/blackjack_tb/dut/bj/dp/entrada_carta[0]} -radix unsigned}
    } \
    -subitemconfig {
        {/blackjack_tb/dut/bj/dp/entrada_carta[3]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/dp/entrada_carta[2]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/dp/entrada_carta[1]} {-height 15 -radix unsigned}
        {/blackjack_tb/dut/bj/dp/entrada_carta[0]} {-height 15 -radix unsigned}
    } \
    /blackjack_tb/dut/bj/dp/entrada_carta

## ── Configurações de visualização ────────────────────────────────
TreeUpdate [SetDefaultTree]
WaveRestoreCursors \
    {{Cursor 1} {0 ps} 0} \
    {{Cursor 2} {100088 ps} 0}
quietly wave cursor active 2

configure wave -namecolwidth   117
configure wave -valuecolwidth   77
configure wave -justifyvalue   left
configure wave -signalnamewidth  1
configure wave -snapdistance    10
configure wave -datasetprefix    0
configure wave -rowmargin        4
configure wave -childrowmargin   2
configure wave -gridoffset       0
configure wave -gridperiod   20000
configure wave -griddelta       40
configure wave -timeline         0
configure wave -timelineunits   ns

update
WaveRestoreZoom {0 ps} {770748121500 ps}
