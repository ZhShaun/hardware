module seven_segment (
    input clk,
    input [3:0] p1_score,
    input [3:0] p2_score,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY
);

    wire [3:0] BCD3, BCD2, BCD1, BCD0;
    reg [3:0] value;

    assign BCD3 = p1_score % 10;
    assign BCD2 = p1_score / 10;
    assign BCD1 = p2_score % 10;
    assign BCD0 = p2_score / 10;

	always @(posedge clk) begin
		case (DIGIT)
			4'b1110: begin
				value = BCD1;
				DIGIT = 4'b1101;
			end
			4'b1101: begin
				value = BCD2;
				DIGIT = 4'b1011;
			end
			4'b1011: begin
				value = BCD3;
				DIGIT = 4'b0111;
			end
			4'b0111: begin
				value = BCD0;
				DIGIT = 4'b1110;
			end
			default: begin
				value = BCD0;
				DIGIT = 4'b1110;
			end
		endcase
	end

    always @(*) begin
        case (value)
            4'd0: DISPLAY = 7'b0000001;
   			4'd1: DISPLAY = 7'b1001111;
   			4'd2: DISPLAY = 7'b0010010;
   			4'd3: DISPLAY = 7'b0000110;
   			4'd4: DISPLAY = 7'b1001100;
   			4'd5: DISPLAY = 7'b0100100;
   			4'd6: DISPLAY = 7'b0100000;
   			4'd7: DISPLAY = 7'b0001111;
   			4'd8: DISPLAY = 7'b0000000;
   			4'd9: DISPLAY = 7'b0000100;
   			default: DISPLAY = 7'b0000100;               		    
        endcase
    end

endmodule 