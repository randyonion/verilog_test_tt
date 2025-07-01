/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output reg [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);


    wire reset = ~rst_n;
    assign uio_out = 0;
    assign uio_oe = 0;
    wire _unuse = &{ena,uio_in,1'b0};

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            uo_out <= 0;
        end else begin
            uo_out[3:0] <= ui_in[7:4] + ui_in[3:0];
            uo_out[7:4] <= 0;
        end
    end


endmodule
