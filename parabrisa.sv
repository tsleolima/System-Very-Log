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

logic [1:0] clock;
logic reset;
logic trava;
logic [5:0] chuva;

always_ff @ (posedge clk_2) begin
	if(~trava) begin clock = clock +1; end
end

logic [1:0] limpador;
logic [2:0] contador_de_gotas;
logic [2:0] count3;
logic [2:0] count2;
logic [1:0] countD;

parameter estado1 = 1, estado3 = 3, estado5 = 5;

always_comb begin
	reset <= SWI[6];
	trava <= SWI[7];
	chuva <= SWI[5:0];
	SEG[7] <= clock[1];
	LED[1:0] <= limpador;
end

always_ff @ (posedge clock[1]) begin

	if(chuva[0]) begin contador_de_gotas = contador_de_gotas + 1; end
	if(chuva[1]) begin contador_de_gotas = contador_de_gotas + 1; end
	if(chuva[2]) begin contador_de_gotas = contador_de_gotas + 1; end
	if(chuva[3]) begin contador_de_gotas = contador_de_gotas + 1; end
	if(chuva[4]) begin contador_de_gotas = contador_de_gotas + 1; end

	unique case (contador_de_gotas)

		estado1: begin
					 if(countD == 1) begin limpador <= 0; count2 = 0; count3 = 0; end
					 else begin countD = countD + 1; end
				 end

		estado3: begin
					 if(count3 == 3) begin limpador <= 1; count3 = 3; count2 = 0; end
					 else begin count3 = count3 + 1; end
				 end
				
		estado5: begin
					 if(count2 == 2) begin limpador <= 2; count2 = 2; count3 = 0; end
					 else begin count2 = count2 + 1; end
				 end
	endcase
	contador_de_gotas = 0;
end

endmodule
