module CapBoardDriver(clk500kHz,state,fets);
	//INPUT:
	//clk: Clock - designed to be 500 kHz
	input clk500kHz;
	//reg [3:0] clkCnt; //Count on clock edges to divide clock.


	//state: state of board - which cap numbers are on.  Each bit corresponds to
	//cap bank (either serial or parallel).
	input [3:0] state;


	//OUTPUT:
	//fets: gets signal that goes into MIC4427 drivers -
	//should be a square wave at 500 kHz - divide clk/2^2.
	output [7:0] fets;

		//Send square wave to MOSFET drivers
	//The number outside the curly braces, {4...}, is a repitition multiplier which serves
	//to create a vector from the square wave for bitwise AND with the board state.
	assign fets[3:0]={4{clk500kHz}} & state;
	assign fets[7:4]=(~fets[3:0]) & state; //Invert square wave for 180-degree phase shift for push-pull transformer drive.
	
endmodule

//CODE GRAVEYARD
//	//Initialize clock count variable.
//	initial begin
//		#0; //Act on zeroth simulation cycle.
//		clkCnt=3'b0; //Zero.
//	end
//
//	//Act on clk positive edges.
//	always @(posedge clk) begin
//		//Divide clk to get slower square wave for driving transformers,
//		//so increment counter.
//		clkCnt=clkCnt+4'b1;
//	end
