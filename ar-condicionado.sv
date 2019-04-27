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


always_ff @ (posedge clk_2) begin
	clock <= clock +1;
end

logic diminuir;
logic aumentar;

always_comb begin
	LED[7] <= clock[1];
	reset <= SWI[7];
	diminuir <= SWI[0];
	aumentar <= SWI[1];
end

logic [2:0] desejo;
logic [2:0] reall;
logic pingando;
logic [3:0] count;
logic teste;

always_comb begin
	LED[2:0] <= desejo;
	LED[6:4] <= reall;
	LED[3] <= pingando;
	LED[5] <= teste;
end

logic [2:0] estado_atual; 
parameter estado0 = 0, estado1 = 1, estado2 = 2;

always_ff @(posedge clock[1] or posedge reset) begin
	if(reset) begin
		desejo <= 0;
		reall <= 0;
		estado_atual <= estado2;
	end
	else begin estado_atual <= estado0;  end
	unique case (estado_atual)
		estado0:begin
				if (aumentar && diminuir) begin estado_atual <= estado0; end
				else if(diminuir && desejo > 0) begin desejo <= desejo - 1; estado_atual <= estado0; end
				else if (aumentar && desejo < 7) begin desejo <= desejo + 1; estado_atual <= estado0; end
				else if (~aumentar && ~diminuir) begin estado_atual <= estado1; end
				end
		
		estado1:begin
				if(desejo > reall) begin reall <= reall +1; estado_atual <= estado0; end
				else if (desejo < reall) begin reall <= reall -1; estado_atual <= estado0; end
				else begin estado_atual <= estado0; end
				end
		estado2:begin
					teste <= 1;
					if(count == 10) begin pingando <= 1; estado_atual <= estado0; end
					else begin count <= count + 1; estado_atual <= estado2; end
				end
	endcase
end

endmodule
