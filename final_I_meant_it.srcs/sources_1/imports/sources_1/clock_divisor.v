module clock_divisor(clk1, clk, clk22, clk18, clk13);
input clk;
output clk1;
output clk22;
output clk18;
output clk13;
reg [21:0] num;
wire [21:0] next_num;

always @(posedge clk) begin
  num <= next_num;
end

assign next_num = num + 1'b1;
assign clk1 = num[1];
assign clk22 = num[21];
assign clk18 = num[17];
assign clk13 = num[12];

endmodule
