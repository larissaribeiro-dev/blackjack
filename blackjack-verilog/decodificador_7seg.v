// ============================================================
// Módulo  : decodificador_7seg
// Autor   : Claude (Assistente de IA – Anthropic)
// Data    : 18 de Abril de 2026
//
// Descrição:
//   Decodificador BCD para display de 7 segmentos.
//   Converte um dígito decimal (0–9) para o padrão de
//   acendimento dos segmentos.
//   Módulo puramente combinacional (sem clock).
//
// Codificação de saída – CÁTODO COMUM (ativo alto):
//   Bit: [6]=g | [5]=f | [4]=e | [3]=d | [2]=c | [1]=b | [0]=a
//
//        aaa
//       f   b
//       f   b
//        ggg
//       e   c
//       e   c
//        ddd
//
// ATENÇÃO PARA A FPGA:
//   Placa DE10-Lite → display de ÂNODO COMUM (ativo baixo).
//   Neste caso, inverter os bits ao conectar ao pino no topo:
//     HEX0 <= ~seg_unidade;   HEX1 <= ~seg_dezena;
//
// Entrada:
//   digito : dígito BCD (0–9); valores 10-15 mostram traço (–)
//
// Saída:
//   segmentos : padrão de 7 segmentos {g, f, e, d, c, b, a}
// ============================================================

module decodificador_7seg (
    input  wire [3:0] digito,    // Dígito BCD 0–9
    output reg  [6:0] segmentos  // Padrão 7 segmentos {g,f,e,d,c,b,a}
);

    always @(*) begin
        case (digito)
				//gfedcba
            4'd0: segmentos = 7'b0111111; // 0 → abcdef  acesos
            4'd1: segmentos = 7'b0000110; // 1 → bc       acesos
            4'd2: segmentos = 7'b1011011; // 2 → abdeg   acesos
            4'd3: segmentos = 7'b1001111; // 3 → abcdg   acesos
            4'd4: segmentos = 7'b1100110; // 4 → bcfg    acesos
            4'd5: segmentos = 7'b1101101; // 5 → acdfg   acesos
            4'd6: segmentos = 7'b1111101; // 6 → acdefg  acesos
            4'd7: segmentos = 7'b0000111; // 7 → abc      acesos
            4'd8: segmentos = 7'b1111111; // 8 → abcdefg acesos
            4'd9: segmentos = 7'b1101111; // 9 → abcdfg  acesos
            default: segmentos = 7'b1000000; // – (traço) p/ inválidos
        endcase
    end

endmodule
