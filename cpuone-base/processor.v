/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;

    /* YOUR CODE STARTS HERE */
	 
	 //wire 
	 wire[31:0] PC_INPUT;
	 wire[31:0] PC_OUTPUT;
	 wire isNotEqual_PC_Plus4, isLessThen_PC_Plus4, overflow_PC_Plus4;
	 
	 wire [16:0] Immediate;
	 
	 wire [4:0] opcode, ALUopcode, RD, RS, RT, shamt;
	 wire[31:0] instruction;
	 wire Rwe, Rdst, ALUinB, ALUop, BR, DMwe, JP, Rwd;
	 wire op_Rtype, op_Addi, op_Sw, op_Lw;
	 
	 wire [4:0] whichcode_overflow;
	 
	 //Rtype
	 wire op_ADD_TMP, op_SUB_TMP, op_AND_TMP, op_OR_TMP, op_SLL_TMP, op_SRA_TMP;
	 wire op_ADD, op_SUB, op_AND, op_OR, op_SLL, op_SRA;
	 
	 
	 //PC
	 pc pc1(clock, reset, PC_INPUT, PC_OUTPUT);
	 alu pcPlus4(PC_OUTPUT, 32'h00000004, 5'b00000,
			5'b00000, PC_INPUT, isNotEqual_PC_Plus4, isLessThan_PC_Plus4, overflow_PC_Plus4);
			
			
	 //imem
	 assign address_imem = PC_OUTPUT[11:0];
	 assign instruction = q_imem;
	 	 
	 
	 //Instruction and regfile
	 assign opcode = instruction[31:27];
	 control_circuit(opcode, Rwe, Rdst, ALUinB, ALUop, BR, DMwe, JP, Rwd, op_Rtype, op_Addi, op_Sw, op_Lw);
	 
	 //overflow
	 //Add 00000
	 is_code is_Add(ALUopcode, 5'b00000, op_ADD_TMP);
	 and and_isadd(op_ADD, op_ADD_TMP, op_Rtype);
	 //Sub 00001
	 is_code is_Sub(ALUopcode, 5'b00001, op_SUB_TMP);
	 and and_isadd(op_SUB, op_SUB_TMP, op_Rtype);
	 
	 whichcode_overflow = op_ADD?5'b00000:op_SUB?5'b00001:op_Addi?5'b00101;
	 
	 
	 
//	 //AND 00010
//	 is_code is_AND(ALUopcode, 5'b00010, op_AND_TMP);
//	 and and_isadd(op_AND, op_AND_TMP, op_Rtype);
//	 //OR 00011
//	 is_code is_OR(ALUopcode, 5'b00011, op_OR_TMP);
//	 and and_isadd(op_OR, op_OR_TMP, op_Rtype);
//	 //SLL 00100
//	 is_code is_SLL(ALUopcode, 5'b00100, op_SLL_TMP);
//	 and and_isadd(op_SLL, op_SLL_TMP, op_Rtype);
//	 //SRA 00101
//	 is_code is_SRA(ALUopcode, 5'b00101, op_SRA_TMP);
//	 and and_isadd(op_SRA, op_SRA_TMP, op_Rtype);
//	 
	  
	 assign RD = instruction[26:22];
	 assign RS = instruction[21:17];
	 assign RT = instruction[16:12];
	 assign shamt = instruction[11:7];
	 assign ALUopcode = op_Rtype?instruction[6:2]:{4'b0000, ALUop};
	 
	 
	 assign Immediate = instruction[16:0];
	 //dmem
	 

	 
	 

endmodule