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

always_ff @(posedge clk_2) begin
	clock = clock + 1;
end

// Entrada

logic [1:0] quantidade;
logic [1:0] quantidadeX;
logic papel;
logic fora;
logic tampa;
logic copiar;

always_comb begin
	reset <= SWI[7];
	copiar <= SWI[0];
	quantidade <= SWI[2:1];
	papel <= SWI[4];
	fora <= SWI[5];
	tampa <= SWI[6];
end

// Saida

logic saida;
logic falta;
logic entupida;

always_comb begin 
	LED[7] <= clock[1];
	LED[0] <= saida;
	LED[1] <= falta;
	LED[2] <= entupida;
end

logic [2:0] estado_atual;
parameter estado0 = 0, estado1 = 1, estado2 = 2, estado3 = 3, estado4 = 4, estado5 = 5;

always_ff @(posedge clock[1]) begin
	if(reset) begin
		estado_atual <= estado0;
		saida <= 0;
		falta <= 0;
		entupida <= 0;
		quantidadeX = 0;
	end
	unique case (estado_atual) 
		estado0:begin
					if(quantidade > 0 && copiar) begin estado_atual <= estado1; end
				end
		estado1:begin
					if(papel && quantidadeX < quantidade) begin
						if(fora) begin entupida <= 1; saida <= 0; estado_atual <= estado3; end
					 	else begin falta <= 0; saida <= 1; quantidadeX = quantidadeX + 1; estado_atual <= estado1; end
					end
					else if (~papel && quantidadeX < quantidade) begin falta <= 1; estado_atual <= estado1; end 
					else if (quantidadeX == quantidade) begin saida <= 0; quantidadeX = 0; end 
				end
		estado3:begin
					if(tampa && ~papel) begin estado_atual <= estado4; end
					else begin estado_atual <= estado3; end
				end
		estado4:begin
					if(~tampa) begin entupida <= 0; estado_atual <= estado1; end
					else begin estado_atual <= estado3; end
				end
	endcase
end

endmodule
