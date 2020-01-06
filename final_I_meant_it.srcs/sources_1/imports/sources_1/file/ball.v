`define LEFT 3'b001
`define RIGHT 3'b010
`define UP 3'b011
`define DOWN 3'b100 
`define CORNER 3'b101

module ball (clk, rst, en, h_cnt, v_cnt, valid, pixel, h, v,
	collisionHSpeed, collisionVSpeed, collisionHSpeedIsLeft,
	collisionVSpeedIsUp, collisionH, collisionV);
	input clk, rst, en;
	input [9:0] h_cnt, v_cnt; // 320 * 240
	output valid;
	output [11:0] pixel;
	output [9:0] h, v;
	input collisionHSpeedIsLeft, collisionVSpeedIsUp;
	input [9:0] collisionHSpeed, collisionVSpeed, collisionH, collisionV;
	
	wire hasCollision;
	wire [2:0] collisionSide;
	
	localparam RESET = 2'b01;
	localparam MOVE = 2'b10;
	localparam COLLISION = 2'b11;
	
	reg [9:0] next_h, next_v;
	reg [1:0] state, next_state;
	reg [2:0] edgeCollided, nextEdgeCollided;
	reg collisionHandleDone, leftOrRight, upOrDown, nextLeftOrRight, nextUpOrDown;
	reg [9:0] h, v; // ball position
	reg [9:0] h_speed, v_speed, next_h_speed, next_v_speed;
	reg [2:0] timer, next_timer;
	CollisionWithPlayerDectector  inst_1 (
		.clk(clk), 
		.rst(rst),
		.ball_h(next_h),
		.ball_v(next_v),
		.player_h(collisionH),
		.player_v(collisionV), 
		.hasCollision(hasCollision),
		.collisionSide(collisionSide)
	);
	
	// movement control
	always @(*) begin
	   if(timer == 5) begin
	       next_timer = 0;
	       if (!leftOrRight) 
			next_h = (h>h_speed) ? h-h_speed : 0;
            else 
                next_h = (h+h_speed < 320) ? h+h_speed : 320;
            
            if (!upOrDown)
                next_v = (v>v_speed) ? v-v_speed : 0;
            else 
                next_v = (v+v_speed<240) ? v+v_speed : 240;
	   end else begin
	       next_timer = timer + 1;
	       next_h = h;
	       next_v = v;
	   end
		
	end 
	
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			state <= RESET;
			h <= 160;
			v <= 120;
			h_speed <= 3;
			v_speed <= 0;
			edgeCollided <= 0;
			leftOrRight <= 1;
			upOrDown <= 1;
			timer <= 0;
		end 
		else begin
		    timer <= next_timer;
			state <= next_state;
			h <= next_h;
			v <= next_v;
			h_speed <= next_h_speed;
			v_speed <= next_v_speed;
			edgeCollided <= nextEdgeCollided;
			leftOrRight <= nextLeftOrRight;
			upOrDown <= nextUpOrDown;
		end 
	end 
		
	always @(*) begin
		next_state = state;
		case (state) 
			RESET: next_state = MOVE;
			MOVE: begin
				if (|edgeCollided | hasCollision)
					next_state = COLLISION;
			end
			COLLISION: begin
				if (collisionHandleDone)
					next_state = MOVE;
			end 
		endcase
	end 
	
	
	
	
	always @(*) begin
		nextEdgeCollided = edgeCollided;
		collisionHandleDone = 0;
		nextLeftOrRight = leftOrRight;
		nextUpOrDown = upOrDown;
		next_h_speed = h_speed;
		next_v_speed = v_speed;
		case (state)
			RESET: begin
				nextEdgeCollided = 0;
				nextLeftOrRight = 1;
				nextUpOrDown = 1;
				next_h_speed = 1;
				next_v_speed = 1;
			end 
			MOVE: begin
				if (next_h <= 3)	nextEdgeCollided = `LEFT;
				else if (next_h >= 316)	nextEdgeCollided = `RIGHT;
				else if (next_v <= 3)	nextEdgeCollided = `UP;
				else if (next_v >= 236)	nextEdgeCollided = `DOWN;
				else nextEdgeCollided = 0;
			end
			COLLISION: begin
				if (|edgeCollided) begin
					case (edgeCollided)
						`LEFT: nextLeftOrRight = 1;
						`RIGHT: nextLeftOrRight = 0;
						`UP: nextUpOrDown = 1;
						`DOWN: nextUpOrDown = 0;
					endcase 
				end 
				else if (hasCollision) begin
					case (collisionSide)
						`LEFT: begin
							nextLeftOrRight = 0;
							if (collisionHSpeedIsLeft) 
								next_h_speed = h_speed;// + collisionHSpeed;
							else 
								next_h_speed = h_speed;// - collisionHSpeed;
						end 
						`RIGHT: begin
							nextLeftOrRight = 1;
							if (collisionHSpeedIsLeft)
								next_h_speed = h_speed;// - collisionHSpeed;
							else 
								next_h_speed = h_speed;// + collisionHSpeed;
						end 
						`UP: begin
							nextUpOrDown = 0;
							if (collisionVSpeedIsUp) 
								next_v_speed = v_speed;// + collisionVSpeed;
							else 
								next_v_speed = v_speed;// - collisionVSpeed;
						end 
						`DOWN: begin
							nextUpOrDown = 1;
							if (collisionVSpeedIsUp)
								next_v_speed = v_speed;// - collisionVSpeed;
							else 
								next_v_speed = v_speed;// + collisionVSpeed;
						end
						`CORNER: begin
							nextUpOrDown = ~upOrDown;
							nextLeftOrRight = ~leftOrRight;
						end 
					endcase 
				end 
				collisionHandleDone = 1;
			end 
		endcase 
	end 
	
	// pixel output
	assign pixel = 12'hfff;
	assign valid = ((abs(h_cnt>>1, h) <= 1) && (abs(v_cnt>>1, v) <= 1)) ? 1 : 0;
	
	function [9:0] abs (input [9:0] a, b);
		begin
			if (a >= b) abs = a - b;
			else abs = b - a;
		end 
	endfunction 
	
	function [9:0] max (input [9:0] a, b);
		begin
			if (a >= b)	max = a;
			else max = b;
		end 
	endfunction
	
	function [9:0] min (input [9:0] a, b);
		begin
			if (a <= b)	min = a;
			else min = b;
		end 
	endfunction
	
endmodule 

module CollisionWithPlayerDectector (
	input clk, 
	input rst,
	input [9:0] ball_h,
	input [9:0] ball_v,
	input [9:0] player_h,
	input [9:0] player_v, 
	output wire hasCollision,
	output reg [2:0] collisionSide
);
	reg [1:0] first, second, next_first, next_second;
	wire h_close, v_close;
	wire h_touch, v_touch;
	
	assign hasCollision = (collisionSide == 0) ? 0 : 1;
	assign h_close = abs(ball_h, player_h) <= 20;
	assign v_close = abs(ball_v, player_v) <= 20;
	assign h_touch = abs(ball_h, player_h) <= 11;
	assign v_touch = abs(ball_v, player_v) <= 11;
	
	always @(*) begin
        if (h_close && v_close) begin
            if (!h_touch && v_touch) begin
                if (player_h >= ball_h) 
                    collisionSide = `LEFT;
                else 
                    collisionSide = `RIGHT;
            end 
            else if (h_touch && !v_touch) begin
                if (player_v >= ball_v)
                    collisionSide = `UP;
                else 
                    collisionSide = `DOWN;
            end 
            else if (!h_touch && !v_touch) begin
                collisionSide = `CORNER;
            end 
            else begin // should be error
                collisionSide = `CORNER;
            end 
        end 
        else begin
            collisionSide = 0;
        end 
	end 
	
	function [9:0] abs (input [9:0] a, b);
		begin
			if (a >= b) abs = a - b;
			else abs = b - a;
		end 
	endfunction 
	
endmodule 






