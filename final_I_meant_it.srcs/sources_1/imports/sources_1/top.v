`define padWidth 10
`define padHeight 10

module top(
   input clk,
   input rst,
   input rx,
   inout wire PS2_DATA,
   inout wire PS2_CLK,
   output reg [3:0] vgaRed,
   output reg [3:0] vgaGreen,
   output reg [3:0] vgaBlue,
   output hsync,
   output vsync
    );

    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    wire been_ready;
    wire [511:0] key_down;
    reg [3:0] key_num;
    wire [15:0] last_change;
    wire[7:0] data_out, data_in;
    wire rx_done;

    reg  [8:0] right_pad_x, right_pad_y;
    reg  [11:0] cur_pixel;
    wire ball_pixel, ble_pixel;
    wire [7:0] ble_h, ble_v;
    wire [9:0] ball_h, ball_v;
    reg flag, collision_paddle_isLeft, collision_paddle_isUp;
    wire clk100, clk18, bleIsLeft, bleIsUp, mouseIsLeft, mouseIsUp, bleValid, mouseValid, ballValid;
    wire [9:0] ble_speed_h, ble_speed_v, mouse_speed_h, mouse_speed_v, mouse_h, mouse_v;
    reg  [9:0] collision_paddle_h, collision_paddle_v, collision_paddle_speed_h, collision_paddle_speed_v;
    reg [15:0] tmp_led;
    wire [3:0] mouse_red, mouse_blue, mouse_green;
    
    always @(*) begin
        if (valid) begin
            if (ballValid)
                {vgaRed, vgaGreen, vgaBlue} = ball_pixel;
            else if (mouseValid)
                {vgaRed, vgaGreen, vgaBlue} = {mouse_red, mouse_green, mouse_blue};
            else 
                {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        end
        else 
            {vgaRed, vgaGreen, vgaBlue} = 0;
    end


    always @(*) begin
        if(1) begin
            collision_paddle_h = mouse_h;
            collision_paddle_v =  mouse_v;
            collision_paddle_speed_h = mouse_speed_h;
            collision_paddle_speed_v = mouse_speed_v;
            collision_paddle_isLeft = mouseIsLeft;
            collision_paddle_isUp = mouseIsUp;
        end else begin
            collision_paddle_h = ble_h;
            collision_paddle_v =  ble_v;
            collision_paddle_speed_h = ble_speed_h;
            collision_paddle_speed_v = ble_speed_v;
            collision_paddle_isLeft = bleIsLeft;
            collision_paddle_isUp = bleIsUp;
        end
    end
    
    mouse mouse_inst(
       .rst(rst),
       .speed_clk(clk18),
       .clk(clk),
       .PS2_CLK(PS2_CLK),
       .PS2_DATA(PS2_DATA),
       .h_cntr_reg(h_cnt),
       .v_cntr_reg(v_cnt),
       .enable_mouse_display(mouseValid),
       .MOUSE_X_POS(mouse_h),
       .MOUSE_Y_POS(mouse_v),
       .MOUSE_X_SPEED(mouse_speed_h),
       .MOUSE_Y_SPEED(mouse_speed_v),
       .MOUSE_LEFT(),
       .MOUSE_MIDDLE(),
       .MOUSE_RIGHT(),
       .MOUSE_NEW_EVENT(),
       .mouse_cursor_red(mouse_red),
       .mouse_cursor_green(mouse_green),
       .mouse_cursor_blue(mouse_blue),
       .speedIsLeft(mouseIsLeft),
       .speedIsUp(mouseIsUp)
    );
    
    ball ball_inst(
       .clk(clk18),
       .rst(rst),
       .en(1'b1),
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(ballValid),
       .pixel(ball_pixel),
       .h(ball_h),
       .v(ball_v),
       .collisionHSpeed(collision_paddle_speed_h),
       .collisionVSpeed(collision_paddle_speed_v),
       .collisionHSpeedIsLeft(collision_paddle_isLeft),
       .collisionVSpeedIsUp(collision_paddle_isUp),
       .collisionH(collision_paddle_h >> 1),
       .collisionV(collision_paddle_v >> 1)
    );
    

    ble_paddle paddle_inst(
      .clk(clk_22),
      .rst(rst),
      .data_out(data_out),
      .rx_done(rx_done),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt),
      .ble_x(ble_h),
      .ble_y(ble_v),
      .ble_speed_x(ble_speed_h),
      .ble_speed_y(ble_speed_v),
      .isLeft(bleIsLeft),
      .isUp(bleIsUp),
      .valid(bleValid),
      .pixel(ble_pixel)
    );
  


     clock_divisor clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22),
      .clk18(clk18)
    );
    
//    clk_wiz_0 u_clk(
//            // Clock in ports
//            .clk_in1(clk),      // input clk_in1
//            // Clock out ports
//            .clk_out1(clk100)
//          );

//    mem_addr_gen mem_addr_gen_inst(
//    .clk(clk_22),
//    .rst(rst),
//    .en(en),
//    .dir(dir),
//    .h_cnt(h_cnt),
//    .v_cnt(v_cnt),
//    .pixel_addr(pixel_addr)
//    );
     
 
//    blk_mem_gen_0 blk_mem_gen_0_inst(
//      .clka(clk_25MHz),
//      .wea(0),
//      .addra(pixel_addr),
//      .dina(data[11:0]),
//      .douta(pixel)
//    ); 
    
    
    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
    

//	BlueTooth_0 u_uart_real (
//              .clk(clk100),            // input wire clk
//              .reset(1'b0),        // input wire reset
//              .rx(rx),              // input wire rx
//              .tx_btn(1'b0),      // input wire tx_btn
//              .data_in(8'b0),    // input wire [7 : 0] data_in
//              .data_out(data_out),  // output wire [7 : 0] data_out
//              .rx_done(rx_done),    // output wire rx_done
//              .tx_done(),    // output wire tx_done
//              .tx()              // output wire tx
//            );
    

endmodule
