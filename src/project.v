/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    reg [7:0] PC;
    reg [7:0] regfile[0:3];       // R0–R3
    reg [7:0] memory[0:31];      // Unified memory
    reg jump;

    wire reset = ~rst_n;
    wire [7:0] PC_next = PC + 1;
    wire [7:0] PC_jump = {4'b0000, imm4};
    wire [7:0] PC_new = jump?PC_jump:PC_next;
    wire [7:0] instr = memory[PC];
    wire [1:0] opcode = instr[7:6];
    wire [1:0] regA   = instr[5:4];
    wire [1:0] regB   = instr[3:2];
    wire [1:0] func   = instr[1:0];
    wire [3:0] imm4   = instr[3:0];

    reg [7:0] alu_result;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 8'd0;
            regfile[0] <= 0;
        end else begin
            PC <= PC_new;  // instruction always from 0x00–0x7F
            jump <= 0;
            case (opcode)
                2'b00: begin // LD reg, [imm]
                    regfile[regA] <= memory[{4'b0001, imm4}];  // data from 0x80–0x8F
                end
                2'b01: begin // ST reg, [imm]
                    memory[{4'b0001, imm4}] <= regfile[regA];  // store to 0x80–0x8F
                end
                2'b10: begin // ALU
                    case (func)
                        2'b00: alu_result = regfile[regA] + regfile[regB]; // ADD
                        2'b01: alu_result = regfile[regA] - regfile[regB]; // SUB
                        2'b10: alu_result = regfile[regA] & regfile[regB]; // AND
                        2'b11: alu_result = regfile[regA] ^ regfile[regB]; // XOR
                    endcase
                    regfile[regA] <= alu_result;
                end
                2'b11: begin // JNZ regA, imm
                  if (regfile[regA] == 8'd0) begin
                        jump <= 1;  // still jump within 0x00–0x0F
                  end else jump <= 0;
                end
            endcase
        end
    end


endmodule
