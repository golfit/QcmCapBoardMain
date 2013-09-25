module CapBoardDecoderMain(clk,swIn,enableSer,enablePar,tuningCodeSer,tuningCodePar,capBankSer,capBankPar,stateSer,statePar);
	//swIn, enable, tuningCode, and ledOut are as defined in CapBoardDecoder.v
	//capBankSer and capBankPar are vectors corresponding to the gates on the MOSFET
	//switches for the (four) serial and (four) parallel capacitors.

	//PINOUT
	//swIn[0]	Location	PIN_40	Yes		
	//swIn[1]	Location	PIN_41	Yes		
	//swIn[2]	Location	PIN_44	Yes		
	//swIn[3]	Location	PIN_46	Yes		
	//swIn[4]	Location	PIN_48	Yes		
	//swIn[5]	Location	PIN_49	Yes		
	//enableSer	Location	PIN_8	Yes		AC24 - enable serial cap bank switching
	//enablePar	Location	PIN_6	Yes		AC25 - enable parallel cap bank switching
	//tuningCodeSer[0]	Location	PIN_36	Yes		AC3 - serial cap bank code
	//tuningCodeSer[1]	Location	PIN_33	Yes		AC6 - serial cap bank code
	//tuningCodeSer[2]	Location	PIN_29	Yes		AC9 - serial cap bank code
	//tuningCodeSer[3]	Location	PIN_25	Yes		AC12 - serial cap bank code
	//tuningCodeSer[4]	Location	PIN_21	Yes		AC15 - serial cap bank code
	//tuningCodeSer[5]	Location	PIN_17	Yes		AC18 - serial cap bank code
	//tuningCodeSer[6]	Location	PIN_11	Yes		AC21 - serial cap bank code
	//tuningCodePar[0]	Location	PIN_35	Yes		AC4 - parallel cap bank code
	//tuningCodePar[1]	Location	PIN_31	Yes		AC7 - parallel cap bank code
	//tuningCodePar[2]	Location	PIN_28	Yes		AC10 - parallel cap bank code
	//tuningCodePar[3]	Location	PIN_24	Yes		AC13 - parallel cap bank code
	//tuningCodePar[4]	Location	PIN_20	Yes		AC16 - parallel cap bank code
	//tuningCodePar[5]	Location	PIN_16	Yes		AC19 - parallel cap bank code
	//tuningCodePar[6]	Location	PIN_10	Yes		AC22 - parallel cap bank code
	//clk	Location	PIN_83	Yes		CLOCK - 2 MHz
	//capBankSer[0]	Location	PIN_70	Yes		U10_2 - Column E (Cap Bank Serial 1)
	//capBankSer[1]	Location	PIN_74	Yes		U9_2 - Column F (Cap Bank Serial 2)
	//capBankSer[2]	Location	PIN_76	Yes		U8_2 - Column G (Cap Bank Serial 3)
	//capBankSer[3]	Location	PIN_79	Yes		U7_2 - Column H (Cap Bank Serial 4)
	//capBankSer[4]	Location	PIN_73	Yes		U10_4 - Column E (Cap Bank Serial 1)
	//capBankSer[5]	Location	PIN_75	Yes		U9_4 - Column F (Cap Bank Serial 2)
	//capBankSer[6]	Location	PIN_77	Yes		U8_4 - Column G (Cap Bank Serial 3)
	//capBankSer[7]	Location	PIN_80	Yes		U7_4 - Column H (Cap Bank Serial 4)
	//capBankPar[0]	Location	PIN_60	Yes		U14_2 - Column A (Cap Bank Parallel 1)
	//capBankPar[1]	Location	PIN_63	Yes		U13_2 - Column B (Cap Bank Parallel 2)
	//capBankPar[2]	Location	PIN_65	Yes		U12_2 - Column C (Cap Bank Parallel 3)
	//capBankPar[3]	Location	PIN_68	Yes		U11_2 - Column D (Cap Bank Parallel 4)
	//capBankPar[4]	Location	PIN_61	Yes		U14_4 - Column A (Cap Bank Parallel 1)
	//capBankPar[5]	Location	PIN_64	Yes		U13_4 - Column B (Cap Bank Parallel 2)
	//capBankPar[6]	Location	PIN_67	Yes		U12_4 - Column C (Cap Bank Parallel 3)
	//capBankPar[7]	Location	PIN_69	Yes		U11_4 - Column D (Cap Bank Parallel 4)
	//stateSer[0]	Location	PIN_54	Yes		Diode12 - state of 1st serial cap bank (Col. E)
	//stateSer[1]	Location	PIN_52	Yes		Diode11 - state of 2nd serial cap bank (Col. F)
	//stateSer[2]	Location	PIN_51	Yes		Diode10 - state of 3rd serial cap bank (Col. G)
	//stateSer[3]	Location	PIN_50	Yes		Diode9 - state of 4th serial cap bank (Col. H)
	//statePar[0]	Location	PIN_58	Yes		Diode16 - state of 1st parallel cap bank (Col. A)
	//statePar[1]	Location	PIN_57	Yes		Diode15 - state of 2nd parallel cap bank (Col. B)
	//statePar[2]	Location	PIN_56	Yes		Diode14 - state of 3rd parallel cap bank (Col. C)
	//statePar[3]	Location	PIN_55	Yes		Diode13 - state of 4th parallel cap bank (Col. D)

	input clk; //Clock - 2 MHz
	reg [2:0] clkCnt; //For dividing the clock to lower rates.
	input [5:0] swIn;
	input enableSer,enablePar;
	input [6:0] tuningCodeSer,tuningCodePar;
	 //Hold square wave signals going to MIC4427 drivers for cap banks.
	 //Last four bits are inversion of first four bits
	 //for 180 degree phase shift of square wave to drive transformers push-pull.
	output [7:0] capBankSer, capBankPar;

	//Variables for storing state of serial and parallel capacitor groups.
	//These are tied to LEDs providing visual diagnosis of which cap banks are on.
	//One bit per cap bank (serial or parallel).
	output [3:0] stateSer, statePar;
	//reg [3:0] stateS, stateP;

	//Initialize clock count variable.
	initial begin
		#0; //Act on zeroth simulation cycle.
		clkCnt=3'b0; //Zero.
	end

	//Act on clk positive edges.
	always @(posedge clk) begin
		//Divide clk to get slower rate wave for driving transformers,
		//so increment counter.
		clkCnt=clkCnt+3'b1;
	end
	
	//Create instances of decoder objects for serial and parallel capacitor banks.
	CapBoardDecoder decoderPar(clk,swIn,enablePar,tuningCodePar,statePar);
	CapBoardDecoder decoderSer(clk,swIn,enableSer,tuningCodeSer,stateSer);

	//TEST: tie state to tuning code inputs.
	//assign stateSer={enableSer, tuningCodeSer[6:4]};
	//assign statePar={enablePar, tuningCodePar[6:4]};
	//assign stateSer=4'b1101;
	//assign statePar=4'b1111;
	
	//Create instances of driver objects - these are responsible for sending
	//square wave signal to MOSFET drivers.
	
	//CapBoardDriver is designed to take a 500 kHz clock.  The point of
	//putting the divide-down action in the main file is to make the CapBoardDriver
	//and other sub-modules less likely to be in need of change.
	
	CapBoardDriver driverSer(clkCnt[2],stateSer,capBankSer);
	CapBoardDriver driverPar(clkCnt[2],statePar,capBankPar);
	
	//assign capBankSer={clk,clk,clk,clk,~clk,~clk,~clk,~clk};
	//assign capBankPar={clk,clk,clk,clk,~clk,~clk,~clk,~clk};//Zero output for parallel cap FET drivers.
	//assign capBankPar={4{~clk}};
		
endmodule
