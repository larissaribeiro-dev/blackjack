transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/Contador_baralho.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/blackjack_top.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/Controle.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/CardDeck.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/registrador_mao.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/detector_estouro.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/decodificador_carta.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/decodificador_7seg.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/DATAPATH.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/controlador_display.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/controlador_as_jogador.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/controlador_as_banca.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/comparador_resultado.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/debouncer.v}
vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/BlackJack_StateMachine.v}

vlog -vlog01compat -work work +incdir+C:/ProjetosQuartus/blackjack_completo {C:/ProjetosQuartus/blackjack_completo/blackjack_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  blackjack_tb

add wave *
view structure
view signals
run -all
