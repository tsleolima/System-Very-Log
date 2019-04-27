// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter NINSTR_BITS = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NINSTR_BITS-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);


logic reset;
logic energia_tomada;
always_comb begin
	SEG[7] <= clk_2;
	reset <= SWI[7];
	energia_tomada <= SWI[0];
end

logic [3:0] num_falhas;
logic [3:0] carga_bateria;

logic energia_saida_noBreak;
logic indicador_energia_bateria;
logic shutdown_computador;

always_comb begin
	LED[3:0] <= num_falhas;
	LED[7:4] <= carga_bateria;
	SEG[0] <= energia_saida_noBreak;
	SEG[6] <= indicador_energia_bateria;
	SEG[3] <= shutdown_computador;
end

parameter estado0 = 0, estado1 = 1, estado2 = 2, estado3 = 3, estado4 = 4, estado5 = 5, estado6 = 6;
logic [2:0] estado_atual;

always_ff @(posedge clk_2) begin
	if(reset) begin
		num_falhas = 0;
		carga_bateria = 0;
		shutdown_computador <= 0;
	end
	else begin
		unique case (estado_atual)
			estado0: begin
					if (energia_tomada) begin estado_atual <= estado1; energia_saida_noBreak <= 1; end
					else begin
							if(carga_bateria < 3) begin shutdown_computador <= 1; estado_atual <= estado4; end 
					 		else begin estado_atual <= estado2; end
					end
				end
			estado1: if(carga_bateria < 15) begin carga_bateria = carga_bateria + 1; estado_atual <= estado0; end
					 else begin carga_bateria = 15; estado_atual <= estado0; end
			estado2: if (~energia_tomada) begin
						 if (carga_bateria >= 3) begin indicador_energia_bateria <= 1; estado_atual <= estado3; end
						 else begin shutdown_computador <= 1; energia_saida_noBreak <= 0; estado_atual <= estado0; end
					 end
					 else begin
					 	 estado_atual <= estado1; 
					 end
			estado3: if (~energia_tomada) begin
						carga_bateria = carga_bateria - 1;
						estado_atual <= estado0;
					 end
					 else begin
					 	estado_atual <= estado1;
					 end
			estado4: if(energia_tomada) begin
						if(shutdown_computador) begin
							estado_atual <= estado5;
						end
					 end
					 else begin shutdown_computador <= 1; estado_atual <= estado4; end
			estado5: if(energia_tomada) begin
						if(shutdown_computador) begin
							estado_atual <= estado6;
						end
					 end
					 else begin shutdown_computador <= 1; estado_atual <= estado4; end
			estado6: if(energia_tomada) begin
						if(shutdown_computador) begin
							shutdown_computador <= 0;
							estado_atual <= estado0;
						end
					 end
					 else begin shutdown_computador <= 1; estado_atual <= estado4; end
		endcase
	end
end

endmodule
