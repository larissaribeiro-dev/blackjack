// ============================================================
// Módulo      : debouncer
// Descrição   : Filtro anti-bounce para botões mecânicos.
//               Sincroniza o sinal assíncrono para evitar metaestabilidade
//               e aplica um atraso (counter) para ignorar o ruído elétrico
//               gerado pela trepidação física do botão.
//               Latência de ~21ms (20'hFFFFF ciclos a 50MHz).
//
// Autor       : Gemini (Assistente de IA – Google)
// Data        : Abril de 2026
// ============================================================

module debouncer (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_out = 1'b0  // Inicializado em 0 para simulação/FPGA
);
    reg [19:0] counter = 20'd0; // Contador inicializado
    reg sync_0 = 1'b0;          // Sincronizador inicializado
    reg sync_1 = 1'b0;          // Sincronizador inicializado

    always @(posedge clk) begin
        // Sincronizador de 2 estágios (cura a metaestabilidade)
        sync_0 <= btn_in;
        sync_1 <= sync_0;

        // Lógica de filtro
        if (sync_1 == btn_out) begin
            counter <= 20'd0;
        end else begin
            counter <= counter + 20'd1;
            if (counter == 20'hFFFFF) begin
                btn_out <= sync_1;
                counter <= 20'd0;
            end
        end
    end
endmodule