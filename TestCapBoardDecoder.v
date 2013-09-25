//`timescale 125ns/1ns

module TestCapBoardDecoder();

//Module inputs - define as registers
reg clk;
reg enable;
reg [6:0] code;
reg [5:0] addr;

//Module outputs - define as wires.
wire [3:0] state;

//Instantiante a CapBoardDecoder object.
CapBoardDecoder d(clk,addr,enable,code,state);

//Define simulation parameters
initial  begin
	$dumpfile ("CapBoardDecoder_tb.vcd"); 
	$dumpvars; 
end 

initial  begin
	$display("\t\ttime,\taddr,\tenable,\tcode,\tstate"); 
	$monitor("%d,\t%b,\t%b,\t%b,\t%b",$time, addr,enable,code,state); 
end 

initial
	#100 $finish; //Stop execution after 100 timesteps.

//
initial begin
	//Initialize inputs to decoder.
	#0
	clk=0; //Initialize clock
	addr=~6'b001000; //Invert address input since "ON" for a switch input means a logic low into the CPLD.
	code=7'b0; //Initialize input code.
	enable=1'b0;
	//assign state=4'b0; //Initialize board state.  Don't need to because wire?

	#10 //Ten unit delay
	code=7'b1111111; //Turn on all input pins to code so that, on next enable, state should be updated with all pins on.
	
	#10 //Ten unit delay
	enable=1'b1; //Trigger change.
	
	#5
	enable=1'b0; //Reset enable bit
	
	#10 //Ten unit delay
	code=7'b0100001; //With internal address=100001, will turn on half of board state.
	
	#10 //Ten unit delay
	enable=1'b1; //Set enable bit and trigger change on board state.
	
	#5 enable=1'b0; //Reset enable bit
	
	#10
	code=7'b0; //Reset tuning code so state will be reset on next enable.
	
	#10
	enable=1'b1; //Trigger last move on state.
	
	#5 enable=1'b0; //Reset enable bit
end

always begin
	#1
	clk=!clk; //Invert clock
end

endmodule
