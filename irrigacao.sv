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
// entradas
logic reset;
logic [1:0] clock;
logic [1:0] chuva;

always_ff @(posedge clk_2) begin
	if(~reset) begin clock = clock + 1; end
end

always_comb begin
	SEG[7] <= clock[1];
	reset <= SWI[6];
	chuva <= SWI[1:0];
end

// saidas
logic saida_pe_caju;
logic saida_pe_cacal;
logic alarme;
logic [1:0] count;

parameter 	estado0 = 0, estado1 = 1, estado2 = 2, estado3 = 3, estado4 = 4, estado5 = 5, estado6 = 6;
logic [2:0] estado_atual; 

always_comb begin
	LED[0] <= saida_pe_caju;
	LED[1] <= saida_pe_cacal;
	LED[2] <= alarme;
end

always_ff @(posedge clock[1]) begin 
	if(reset || chuva == 3) begin
		saida_pe_cacal <= 0;
		saida_pe_cacal <= 0;
		if(count == 3) begin estado_atual <= estado6; end 
		else begin 	
			count = count + 1;
			estado_atual <= estado0;
		end
	end
	unique case (estado_atual)
		estado0:
				begin 
				if(chuva == 0 || chuva == 1) begin estado_atual <= estado1; end
				end
		estado1:
				begin
				if(chuva == 0 || chuva == 1) begin estado_atual <= estado2; end
				end
		estado2: 
				begin 
					if(chuva == 0) begin estado_atual <= estado4; end 
					else if (chuva == 1) begin saida_pe_cacal <= 1; estado_atual <= estado3; end  
				end
		estado3:begin
					saida_pe_cacal <= 0; estado_atual <= estado0; 
				end
		estado4:begin
					saida_pe_cacal <= 1; saida_pe_caju <= 1; estado_atual <= estado5;
				end
		estado5:begin
					if(saida_pe_caju) begin saida_pe_caju <= 0; estado_atual <= estado5; end
					else if (saida_pe_cacal) begin saida_pe_cacal <= 0; estado_atual <= estado0; end
				end
		estado6: begin alarme <= 1; estado_atual <= estado0; end 
	endcase
end

endmodule
