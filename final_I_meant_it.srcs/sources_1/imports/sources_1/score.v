`define GATE_WIDTH 5
`define GATE_UPPER_BOUND 100
`define GATE_LOWER_BOUND 200

module score (
    input clk, 
    input rst,
    input [9:0] ball_h,
    input [9:0] ball_v,
    input restart_handle_done,
    output [3:0] player_1_score,
    output [3:0] player_2_score,
    output reg restart,
    output game_over,
    output who_win
);

    reg next_restart;
    reg player_1_win, player_2_win;

    scoreboard board (
        .clk(clk), 
        .rst(rst),
        .en(1), // restart == 1 means need to restart, don't score  
        .player_1_win(player_1_win),
        .player_2_win(player_2_win),
        .player_1_score(player_1_score),
        .player_2_score(player_2_score),
        .game_over(game_over),
        .who_win(who_win)
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            restart <= 0;
        end
        else begin
            restart <= next_restart;
        end
    end

    // determine who wins, restart the game if handled 
    always @(*) begin
        {player_1_win, player_2_win} = 0;
        next_restart = 0;

        if (!restart) begin
            if (ball_h <= `GATE_WIDTH && is_v_inbound(ball_v)) begin
                player_2_win = 1;
                next_restart = 1;
            end
            else if (ball_h >= 320-`GATE_WIDTH && is_v_inbound(ball_v)) begin
                player_1_win = 1;
                next_restart = 1; 
            end
        end
        else if (restart_handle_done)
            next_restart = 0;
    end  


    function is_v_inbound (input [9:0] v);
        begin
            if (v >= `GATE_UPPER_BOUND && v <= `GATE_LOWER_BOUND)
                is_v_inbound = 1;
            else 
                is_v_inbound = 0; 
        end 
    endfunction

endmodule // scoring system 

module scoreboard (
    input clk, 
    input rst,
    input en,
    input player_1_win, // 'win' here means make the score
    input player_2_win,
    output reg [3:0] player_1_score,
    output reg [3:0] player_2_score,
    output reg game_over,
    output reg who_win // 'win' here means win the game 
);

    reg [3:0] next_player_1_score;
    reg [3:0] next_player_2_score;
    reg next_who_win;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            player_1_score <= 0;
            player_2_score <= 0;
            who_win <= 0;
        end 
        else if (en && !game_over) begin
            player_1_score <= next_player_1_score;
            player_2_score <= next_player_2_score;
            who_win <= next_who_win;
        end
    end 

    // scoring 
    always @(*) begin
        next_player_1_score = player_1_score;
        next_player_2_score = player_2_score;

        if (player_1_win) 
            next_player_1_score = player_1_score + 1;
        else if (player_2_win)
            next_player_2_score = player_2_score + 1;
    end

    // determine if game_over 
    always @(*) begin
        next_who_win = who_win;

        if (player_1_score >= 7 || player_2_score >= 7) begin
            game_over = 1;
            if (player_1_score >= 7)
                next_who_win = 0;
            else 
                next_who_win = 1;
        end 
        else 
            game_over = 0;
    end


endmodule