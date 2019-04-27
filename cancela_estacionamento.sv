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
logic cancela1;
logic cancela2;

always_comb begin
	cancela1 <= SWI[0];
	cancela2 <= SWI[7];
	reset <= SWI[5];
end

logic [4:0] num_carros;
logic cancela_sinal_aberta1;
logic cancela_sinal_aberta2;

parameter estado0 = 0, estado1 = 1, estado2 = 2;
logic [1:0] estado_atual;

always_ff @(posedge clk_2 or posedge reset) begin
	if(reset) begin
		estado_atual <= estado0;
		num_carros = 0;
		cancela_sinal_aberta1 <= 0;
		cancela_sinal_aberta2 <= 0;
	end
	else begin
		unique case (estado_atual) 
			estado0: begin 
					if (num_carros < 10 && cancela1) begin cancela_sinal_aberta1 <= 1; estado_atual <= estado1;  end
					else if (num_carros > 0 && cancela2) begin cancela_sinal_aberta2 <= 1; estado_atual <= estado2; end	
				end	 
			estado1: if(!cancela1) begin num_carros = num_carros + 1; cancela_sinal_aberta1 <= 0; estado_atual <= estado0; end
			estado2: if(!cancela2) begin num_carros = num_carros - 1; cancela_sinal_aberta2 <= 0; estado_atual <= estado0; end
		endcase
	end
end	

always_comb begin
	LED[6:3] <= num_carros;
	LED[7] <= clk_2;
	LED[0] <= cancela_sinal_aberta1; 
	LED[1] <= cancela_sinal_aberta2;
end

endmodule
