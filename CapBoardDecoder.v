module CapBoardDecoder(clk,swIn,enable,tuningCode,boardOut);
//CapBoardDecoder - module for CPLD controlling state on Cap Board - decodes
//global tuning configuration state by comparing the global number to the
//board address.  Handles 4 IDs per board.
//Ted Golfinopoulos, v1.0 begun on 7 September 2011
//Ted Golfinopoulos, v2.0 on 13 October 2011 - trigger on enable level rather than
//															enable edge - get rid of issue wherein
//															code bits get interpreted internally as
//															enable edges (circuit only, not in simulations).

//NOTE: Default type is WIRE (NET variety type)

 input clk; //Needed clock because there is cross-talk in the CPLD and bounce on signals.
 reg [3:0] clkCnt; //Counter for clock.
 reg [3:0] clkCntAddr; //Counter for timing how long address switch state has been stable.
  
 //swIn: Contains binary number corresponding to switches holding board address.
 //When switches are ON, state is LOW.  So inversion is necessary.
 //Also, there are four unique IDs per board:
 //addr, addr+1, addr+2, and addr+3
 //Original design plans for around 20 boards, but there are only 6 switches
 //per board, so need to multiply the board number by a scale number, the
 //number of unique IDs per board.
 //So address number must process swIn by first INVERTing and then
 //multiplying the number.
 input [5:0] swIn;
 //21 May 2012 - add hysterisis to address to see if it fixes trip problem (i.e. address being modified eroneously during operation).
 reg [5:0] swInPrevious;
 reg [5:0] swInStable;
 
 reg [6:0] addr;
  
 //enable: when this bit is high, it is okay to change the tuning state.
 //It is set by the master controller and makes sure output is stable first.
 //Make a register.
 input enable;

 //tuningCode: Holds binary number corresponding to global tuning number.
 //Compare to this number to determine which IDs to turn on.
 input [6:0] tuningCode;
 
 //boardOut: This holds the state of the board - each bit corresponds to
 //one of the board ID cap switches.  ON means switch in corresponding cap ID.
 //boardState: register to hold board output in procedural blocks.
 output [3:0] boardOut;
 reg [3:0] boardState;
 
 //Parameterize the number of capacitor levels per board.  That is, there
 //are numIDsPerBoard levels for serial or parallel caps.
 parameter numIDsPerBoard=4;
 parameter waitBit=2; //enable must be on until clkCnt[waitBit] goes high.  2 clock cycles at 4 MHz causes intermittent turn-on with the wrong trigger bit.  4 clock cycles seems to be enough to eliminate false turn-on.

 parameter ADDR_WAIT=4'b1111;
 
 initial begin
	#0;
	clkCnt = 3'b0; //Initialize clock counter.
	boardState = 4'b0; //Initialize so that all capacitors are off - baseload, only.
	addr=7'b0000001; //Initialize so that all capacitors are off - baseload, only.
 end
 
 //DECODE TUNING CODE AND UPDATE BOARD STATE:
 //When the ENABLE bit has a rising edge, sample the tuning number
 //and trigger an update in state.
 always @(posedge clk) begin
		//enable must be on for certain number of consecutive clock cycles.
		if (enable==1'b1) clkCnt=clkCnt+3'b1; //Increment counter.
		else clkCnt=3'b0; //Else, zero out clkCnt.
		
		//Update state condition: enable has been asserted for a sufficient amount of time,
		//as measured on counter.
		if(clkCnt[waitBit]==1'b1 && enable==1'b1) begin
				//#4 Simulate delay
				boardState = {tuningCode>=(addr+7'b11),
								tuningCode>=(addr+7'b10),
								tuningCode>=(addr+7'b01),
								tuningCode>=(addr+7'b00)};
				clkCnt = 3'b0; //Refresh clock counter.
		end
 end

//Force address to hold new state for some time before changing. 
 always @(posedge clk) begin
	//If the switch state changes, start a counter.  The counter is incremented
	//every clock cycle that the current switch state has the same value as the
	//changed-to state that initiated the counter.  Once the counter has reached
	//a threshold value, the switch state is assumed stable, and the register
	//used to calculate the address is updated.
	//Note that initially, the board won't know its address.
	if(swInPrevious != swIn) begin
		swInPrevious=swIn; //Start tracking new switch state.
		clkCntAddr=1'b0; //Zero counter.
	end else if(swInPrevious == swIn && clkCntAddr < ADDR_WAIT) begin
		clkCntAddr=clkCntAddr+1'b1; //Increment timer since switch state hasn't changed.
	end else begin
		swInStable=swInPrevious; //Update stable switch state 
	end

	//Process switch input to derive useful board address.
	//Remember: addr is bitwise-inverted because a HIGH on the switch corresponds to
	//the switch being in the OFF state.	
	addr=((~swInStable) - 1'b1)*numIDsPerBoard+1'b1;
	//addr=3'b101; //Lock for Board #2 to see if this fixes trip.
	//addr=1'b1; //Lock for Board #1 to see if this fixes trip in Board #1.
 end
 
 //Set board state output from register to net (wires).
 assign boardOut=boardState; 
 
 endmodule
