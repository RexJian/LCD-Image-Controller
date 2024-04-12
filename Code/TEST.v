
`timescale 1ns/1ps
`define CYCLE 0.44
`define EXPECT "./tb3_goal.dat" 
`define CMD "./cmd3.dat" 
`define IMAGE "image3.dat"
`include "LCD_CTRL.v"

module TEST;

parameter IMAGE_N_PAT = 64; 
parameter CMD_N_PAT = 46; 
parameter t_reset = `CYCLE*2;
reg clk;
reg reset;
reg [20] cmd;
reg cmd_valid;
reg [7:0] out_mem [0:63];
wire IROM_rd;
wire [5:0] IROM_A;
wire IRAM_valid;
wire [7:0] IRAM_D;
wire [5:0] IRAM_A;
wire busy;
wire done;
wire [7:0] IROM_Q;
integer i, j, k, l, err;
reg over;
reg [3:0] cmd_mem [0: CMD_N_PAT-1];


LCD_CTRL_LCD_CTRL (.clk (clk), .reset(reset), .cmd(cmd), .cmd_valid (cmd_valid),.IROM_rd (IROM_rd), .IROM_A (IROM_A), .IROM_Q(IROM_Q),.IRAM_valid (IRAM_valid), .IRAM_D (IRAM_D), .IRAM_A(IRAM_A),.busy (busy), .done(done));
IROM IROM_1(.IROM_rd (IROM_rd), .IROM_data(IROM_Q), .IROM_addr (IROM_A), .clk(clk), .reset(reset));
IRAM IRAM_1 (.clk(clk), .IRAM_data(IRAM_D), .IRAM_addr (IRAM_A), .IRAM_valid (IRAM_valid));
initial $readmemh (CMD, cmd_mem);
initial $readmemh (EXPECT, out_mem);

initial begin
$toggle_count ("TEST. LCD_CTRL"); 
$toggle_count_mode(1);
$fsdbDumpfile ("LCD_CTRL.fsdb");
$fsdbDumpvars;
$fsdbDumpMDA;

#100 $display("------------------ERROR------------------\n")
$finish;
end
initial begin
  clk = 1'b0;
  reset = 1'b0;
  over = 1'b0;
  l = 0;
  err = 0;
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
  @(negedge clk) reset = 1'b1;
  #t_reset       reset = 1'b0;
end


always @(negedge clk)
begin
  begin
  if (l< CMD_N_PAT) begin
    if(!busy)
    begin
      cmd = cmd_mem[l];
      cmd_valid = 1'b1;
      1=1+1;
    end 
    else
      cmd_valid = 1'b0;
  end
  else
  begin
    1=1;
    cmd_valid = 1'b0;
  end
  end
end

initial @(posedge done)
begin
  $toggle_count_report_flat ("LCD_CTRL_rtl.tcf", "TEST.LCD_CTRL");
  for (k=0;k<64; k=k+1) begin
    if( IRAM_1.IRAM_M[k] !== out_mem[k])
      begin
      $display ("ERROR at %d:output %h !=expect %h ", k, IRAM_1.IRAM_M[k], out_mem[k]); 
      err = err+1;
      end
    else if (out_mem[k] === 8' dx)
      begin
      $display ("ERROR at %d:output %h !=expect %h ",k, IRAM_1.IRAM_M[k], out_mem[k]); 
      err=err+1;
      end
  over=1'b1;
end


  begin
  if (err === 0 && over===1'b1 ) begin
     $display ("All data have been generated successfully!\n");
     $display("----PASS ----\n");
     #10 $finish;
  end
  else if( over===1'b1 )
  begin
    $display ("There are %d errors!\n", err); 
    $display("--------------------------\n");
    #10 $finish;
  end
end
end
endmodule

module IROM (IROM_rd, IROM_data, IROM_addr, clk, reset);
input IROM_rd;
input [5:0] IROM addr;
output [7:0] IROM_data;
input clk, reset;
reg [7:0] sti_M [0:63]; 
integer i;
reg [7:0] IROM_data;
initial begin
  @ (negedge reset) $readmemb (`IMAGE, sti_M); 
  end
always@(negedge clk)
  if (IROM_rd) IROM_data <= sti_M[IROM_addr];
endmodule


module IRAM (IRAM_valid, IRAM_data, IRAM_addr, clk);
input IRAM_valid;
input [5:0] IRAM_addr;
input [7:0] IRAM_data;
input clk;
reg [7:0] IRAM_M [0:63];
integer i;
initial begin
  for (i=0; i<=63; i=i+1) IRAM_M[i];
end

always@(negedge clk)
  if (IRAM_valid) IRAM_M[IRAM_addr] <= IRAM_data;
endmodule