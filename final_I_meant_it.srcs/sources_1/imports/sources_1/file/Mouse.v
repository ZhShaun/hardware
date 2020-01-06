module mouse(
		input rst,
		input speed_clk,
    input clk,
    input [9 : 0] h_cntr_reg,
    input [9 : 0] v_cntr_reg,
    output enable_mouse_display,
    output [9 : 0] MOUSE_X_POS,
    output [9 : 0] MOUSE_Y_POS,
		output reg [9 : 0] MOUSE_X_SPEED,
		output reg [9 : 0] MOUSE_Y_SPEED,
		output reg speedIsLeft, 
		output reg speedIsUp,
    output MOUSE_LEFT,
    output MOUSE_MIDDLE,
    output MOUSE_RIGHT,
    output MOUSE_NEW_EVENT,
    output [3 : 0] mouse_cursor_red,
    output [3 : 0] mouse_cursor_green,
    output [3 : 0] mouse_cursor_blue,
    inout PS2_CLK,
    inout PS2_DATA
);

    wire [3:0] MOUSE_Z_POS;
		reg [9:0] old_X_pos, old_Y_pos;
		wire [9:0] next_old_X_pos, next_old_Y_pos;
    
		always @(posedge speed_clk, posedge rst) begin
			if (rst) begin
				old_X_pos <= 0;
				old_Y_pos <= 0;
			end 
			else begin
				old_X_pos <= next_old_X_pos;
				old_Y_pos <= next_old_Y_pos;
			end 
		end 
		
		assign next_old_X_pos = MOUSE_X_POS;
		assign next_old_Y_pos = MOUSE_Y_POS;
		
		always @(*) begin
			if (MOUSE_X_POS >= old_X_pos) begin
				speedIsLeft = 0;
				MOUSE_X_SPEED = MOUSE_X_POS - old_X_pos;
			end 
			else begin
				speedIsLeft = 1;
				MOUSE_X_SPEED = old_X_pos - MOUSE_X_POS;
			end
		
			if (MOUSE_Y_POS >= old_Y_pos) begin
				speedIsUp = 0;
				MOUSE_Y_SPEED = MOUSE_Y_POS - old_Y_pos;
			end 
			else begin
				speedIsUp = 1;
				MOUSE_Y_SPEED = old_Y_pos - MOUSE_Y_POS;
			end
		end 
			
		
    MouseCtl #(
      .SYSCLK_FREQUENCY_HZ(108000000),
      .CHECK_PERIOD_MS(500),
      .TIMEOUT_PERIOD_MS(100)
    )MC1(
        .clk(clk),
        .rst(1'b0),
        .xpos(MOUSE_X_POS),
        .ypos(MOUSE_Y_POS),
        .zpos(MOUSE_Z_POS),
        .left(MOUSE_LEFT),
        .middle(MOUSE_MIDDLE),
        .right(MOUSE_RIGHT),
        .new_event(MOUSE_NEW_EVENT),
        .value(12'd0),
        .setx(1'b0),
        .sety(1'b0),
        .setmax_x(1'b0),
        .setmax_y(1'b0),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA)
    );
    
		/*
    MouseDisplay MD1(
        .pixel_clk(clk),
        .xpos(MOUSE_X_POS),
        .ypos(MOUSE_Y_POS),
        .hcount(h_cntr_reg),
        .vcount(v_cntr_reg),
        .enable_mouse_display_out(enable_mouse_display),
        .red_out(mouse_cursor_red),
        .green_out(mouse_cursor_green),
        .blue_out(mouse_cursor_blue)
    );
		*/
		
		SquareDisplay SQ1(
				.rst(rst),
        .xpos(MOUSE_X_POS),
        .ypos(MOUSE_Y_POS),
        .hcount(h_cntr_reg),
        .vcount(v_cntr_reg),
        .enable_mouse_display(enable_mouse_display),
        .red_out(mouse_cursor_red),
        .green_out(mouse_cursor_green),
        .blue_out(mouse_cursor_blue)
    );

endmodule

module SquareDisplay (
	input rst, 
	output reg enable_mouse_display,
	input [9:0] xpos,
	input [9:0] ypos,
	input [9:0] hcount,
	input [9:0] vcount,
	output reg [3:0] red_out, 
	output reg [3:0] green_out,
	output reg [3:0] blue_out
);
	
	always @(*) begin
		{red_out, green_out, blue_out} = 0;
		if (rst) 
			enable_mouse_display = 0;
		else if ((abs(xpos>>1, hcount>>1) <= 10) && (abs(ypos>>1, vcount>>1) <= 10))
			enable_mouse_display = 1;
		else 
			enable_mouse_display = 0;
	end 

	function [9:0] abs (input [9:0] a, b);
		begin
			if (a >= b) abs = a - b;
			else abs = b - a;
		end 
	endfunction 
endmodule

