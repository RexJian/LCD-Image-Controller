
`timescale 1ns/1ps
//cadence translate_off
`include "/usr/chipware/CW_minmax.v" 
//cadence translate_on

module LCD_CTRL (clk,
reset,
cmd,
cmd_valid,
IROM Q,
IROM_rd,
IROM_A, 
IRAM_valid,
IRAM_D,
IRAM_A,
busy,
done);
input clk;
input reset;
input [2:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output reg [5:0] IROM_A;
output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output busy;
output done;
//Write Your Design Here
integer i;
reg [6:0] process_cnt;
reg [2:0] x,y;
reg [7:0] img_data [0:63];
reg [6:0] img_idx, idx1, idx2, idx3, idx4;
reg [8:0] add1_1, add1_2;
reg [9:0] add2;
reg cmd_done;
reg [2:0] current_state, next_state;
wire[7:0] min_val, max_val;
wire[1:0] min_idx, max_idx;
wire[31:0] combine_data;
parameter INIT = 0, READ_ROM_DATA = 1, READ_CMD = 2, PROCESS = 3, END = 4;

always @(*) begin
  case (current state)
    INIT: next state = reset? INIT READ ROM DATA;
    READ_ROM_DATA: next_state= (IROM_A == 6'd63) ? READ_CMD: READ_ROM_DATA;
    READ CMD: next state = cmd valid ? PROCESS: READ CMD;
    PROCESS: next_state = (cmd == 3'd0 && process_cnt == 7'd65) ? END ((cmd >= 3'b1 && cmd <= 3'd4 && process_cnt == 7'd1) || (cmd >= 3'd5 && cmd <= 3'd6 && process_cnt == 7'd5) || (cmd == 3'd7 && process cnt == 7'd7) ? READ CMD: PROCESS);
    END: next state = reset? INIT : END;
    default next_state = INIT; 
  endcase
end

assign busy = (current_state == READ_ROM_DATA || current_state == INIT || ~cmd_done || IROM_rd ) ? 1'b1 1'b0; 
assign done = (current_state== END) ? 1'b1 : 1'b0;
assign combine_data = {img_data[idx1], img_data[idx2], img_data[idx3], img_data[idx4]};
assign IROM_rd = (current_state== READ_ROM_DATA);

CW minmax# (8,4) FIND_MIN(.a(combine_data), .tc(1'b0), .min max(1'b0), .value(min val), .index (min idx)); 
CW_minmax#(8,4) FIND_MAX(.a(combine_data), .tc(1'b0), .min_max (1'b1), .value(max_val), .index(max_idx));

always @(posedge clk) begin
  if (reset)
    IRAM_valid <=1'b0;
  else if (cmd == 3'd0 && IRAM_A != 6'd63 && process_cnt != 7'd0)
    IRAM_valid <=1'b1;
  else
    IRAM valid <=1'b0;
end

always @(posedge clk) begin
  if (reset)
    IRAM D <= 8'd0;
  else if (cmd == 3'd0 && IRAM_A != 6'd63 && process_cnt != 7'd0) 
    if (~IRAM_valid)
       IRAM_D <= img_data[0];
     else
       IRAM_D <= img_data[IRAM_A + 6'd1];
  else
    IRAM_D <= IRAM_D;  
end


always @(posedge clk) begin
  if (reset)
    IRAM_A <= 6'd0;
  else if (cmd == 3'd0 && process_cnt != 7'd65 && process_cnt >= 7'd2) 
    IRAM_A <= IRAM_A+ 6'd1;
  else
    IRAM_A <= IRAM_A;
end

always @(posedge clk) begin
  if (reset)
    add1_1 <= 9'd0;
  else if (cmd == 3'd7 && process_cnt == 7'd4) 
    add1_1 <= img_data[idx1] + img_data[idx2]; 
  else
    add1_1 <= add1_1;
end

always @(posedge clk) begin
  if (reset)
    add1_2<= 9'd0;
  else if (cmd == 3'd7 && process_cnt == 7'd4)
    add1_2 <= img_data[idx3] + img_data[idx4]; 
  else
    add1 2 <= add1_2;
end

always @(posedge clk) begin
  if (reset)
    add2 <= 10'd0;
  else if (cmd == 3'd7 && process_cnt == 7'd5) 
    add2 <= (add1_1 + add1_2) >>2;
  else
    add2 <= add2;
end


always @(posedge clk) begin 
  if (reset) begin
    for(i=0; i< 64; i=i+1)
      img_data[i] <= 8'd0;
  end
  else if (current_state == READ_ROM_DATA)
    img_data[IROM_A] <= IROM_Q;
  else if (cmd == 3'd5 && process_cnt == 7'd4) begin
    img_data[idx1] <= max_val;
    img_data[idx2] <= max_val;
    img_data[idx3] <= max_val;
    img_data[idx4] <= max_val;
  end
  else if (cmd == 3'd6 && process_cnt == 7'd4) begin
    img_data[idx1] <= min_val;|
    img_data[idx2] <= min_val;
    img_data[idx3] <= min_val;
    img_data[idx4] <= min_val;
  end
  else if (cmd == 3'd7 && process_cnt == 7'd6) begin
    img_data[idx1] <= add2;
    img_data[idx2] <= add2;
    img_data[idx3] <= add2;
    img_data[idx4] <= add2;
  end
  else begin
    for(i=0; i<64; i=i+1)
      img_data[i] <= img_data[i];
  end
end

always @(posedge clk) begin 
  if (reset)
    process_cnt <= 7'd0;
  else if (next_state == PROCESS) 
    process_cnt <= process_cnt + 7'd1;
  else
    process_cnt <= 7'd0;
end


always @(posedge clk) begin
  if (reset)
    cmd_done <=1'b1;
  else if (current_state== READ_CMD || current_state == PROCESS) begin
    case (cmd)
      3'd0: cmd_done <= process_cnt != 7'd65 ? 1'b0 : 1'b1;
      3'd1: cmd_done <= process_cnt != 7'd1 ? 1'b0 : 1'b1; 
      3'd2: cmd_done <= process_cnt != 7'd1 ? 1'b0 : 1'b1;
      3'd3: cmd_done <= process_cnt != 7'd1 ? 1'b0 : 1'b1;
      3'd4: cmd_done <= process_cnt != 7'd1 ? 1'b0 : 1'b1;
      3'd5: cmd_done <= process_cnt != 7'd5 ? 1'b0 : 1'b1;
      3'd6: cmd_done <= process_cnt != 7'd5 ? 1'b0 : 1'b1;
      3'd7: cmd_done <= process_cnt != 7'd7 ? 1'b0: 1'b1;
    endcase
  end
  else
    cmd_done <= cmd_done;
end

always @(posedge clk) begin
  if (reset)
    idx1 <= 7'd27;
  else if(process_cnt == 7'd3 && cmd >= 3'd5)
    idx1 <= idx4 - 7'd9;
  else
    idx1 <= idx1;
end

always @(posedge clk) begin
  if (reset)
    idx2 <= 7'd28;
  else if(process_cnt == 7'd3 && cmd >= 3'd5)
    idx2 <= idx4 - 7'd8;
  else
    idx2 <= idx2;
end

always @(posedge clk) begin
  if (reset)
    idx3 <= 7'd35;
  else if(process_cnt == 7'd3 && cmd >= 3'd5)
    idx3 <= idx4 - 7'd1;
  else
    idx3 <= idx3;
end


always @(posedge clk) begin 
  if (reset)
    idx4<= 7'd36;
  else if (cmd >= 3'd5)
    if (process_cnt == 7'd1) 
      idx4 <= {4'd0,y} << 3;
    else if(process_cnt == 7'd2)
      idx4 <= idx4 + {4'd0,x};
    else
      idx4<= idx4;
  else
    idx4<= idx4;
end

always @(posedge clk) begin
  if (reset)
    x <= 3'd4;
  else if (current_state== PROCESS && process_cnt == 7'd1) begin 
    case (cmd)
      3'd3: x <= (x == 3'd1) ? x : x-3'd1;
      3'd4: x <= (x == 3'd7) ? x : x+3'd1;
    endcase
  end
  else
    x <= x;
end

always @(posedge clk) begin
  if (reset)
    y <= 3'd4;
  else if (current_state == PROCESS && process_cnt == 7'd1) begin
    case(cmd)
      3'd1: y <= (y == 3'd1) ? y : y-3'd1;
      3'd2: y <= (y == 3'd7) ? y : y+3'd1;
    endcase
  end
  else
    y <= y;
end

always @(posedge clk) begin
  if (reset)
    current_state <= INIT;
  else
    current_state <= next_state;
end

always @(posedge clk) begin
  if(reset)
    IROM_A <= 6'd0;
  else if(IROM_rd)
    IROM_A <= IROM_A + 6'd1;
  else
    IROM_A <= 6'd0;
end

endmodule
