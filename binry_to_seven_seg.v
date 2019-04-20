module topModule(In, Clk, Seg_sel, Seg_data ,Seg_debug ,LED_on ,Reset);
	
	input[11:0] In;
	input Clk;
	input Reset;
	
	output [3:0] Seg_sel;
	output [7:0] Seg_data;
	
	// debug output 
	output [3:0] Seg_debug;
	output LED_on;
	
	assign LED_on = 1;
	
	wire[3:0] bcd1,bcd2,bcd3;
	wire carry1,carry2,carry3;
	
	wire[7:0] seg1,seg2,seg3, seg4;
	
	hex2bcd first(In[3:0],bcd1 , 0, carry1);
	hex2bcd second(In[7:4],bcd2 ,carry1 , carry2);
	hex2bcd third(In[11:8],bcd3 ,carry2 , carry3);
	

	bcd2SevSeg bcd2SevSeg1(bcd1, seg1);
	bcd2SevSeg bcd2SevSeg2(bcd2, seg2);
	bcd2SevSeg bcd2SevSeg3(bcd3, seg3);
	bcd2SevSeg bcd2SevSeg4({3'b0,carry3}, seg4);
	
	switch time_multiplexing(Clk, seg1, seg2, seg3, seg4, Seg_data, Seg_sel, Seg_debug, Reset); 
	


endmodule

module hex2bcd(in, out, carry_in, carry_out);
	reg [3:0] sum;
	input[3:0] in;
	input carry_in;
	
	output reg[3:0] out;
	output reg carry_out;
	
	always @(*)
	begin
		sum = in + carry_in;
		if (sum <= 9)
		begin
			carry_out = 0;
			out = sum;
		end
		else 
		begin
			carry_out = 1;
			out = sum - 10;
		end
	end
	
	
endmodule


module bcd2SevSeg(in, out);

	input [3:0] in;
	output reg [7:0] out;
	
	always @(*)
	begin
	case (in)
	
	0: out = 8'b00111111;
	1: out = 8'b00000110;
	2: out = 8'b01011011;
	3: out = 8'b01001111;
	4: out = 8'b01100110;
	5: out = 8'b01101101;
	6: out = 8'b01111101;
	7: out = 8'b00000111;
	8: out = 8'b01111111;
	9: out = 8'b01101111;
	default:
		out=8'b0;
	endcase
	
	end
endmodule

module switch(clk, bin1,bin2,bin3,bin4,seg_data,seg_sel, seg_debug, reset); 
	
	input clk;
	input reset;
	input [7:0] bin1;
	input [7:0] bin2;
	input [7:0] bin3;
	input [7:0] bin4;
	
	output reg[3:0] seg_debug;
	output reg[3:0] seg_sel; //= 4'b0001;
	output reg[7:0] seg_data;
	
	reg[31:0] counter;
	
	
	always @(posedge clk)
		begin 
		
		// reset function
		if (reset == 0)
		begin
			counter = 0;
			seg_sel = 4'b0010;
		end
		
		counter = counter + 1;
		
		if (counter > 40000)
			begin
				seg_sel = {seg_sel[2:0], seg_sel[3]};
				seg_debug = seg_sel;
				counter = 0;
			end
		
		case (seg_sel)
			1: seg_data = bin1;
			2: seg_data = bin2;
			3: seg_data = bin3;
			4: seg_data = bin4;
			//default:
				//seg_data = 8'b0;
		endcase
		
		end
	
endmodule


