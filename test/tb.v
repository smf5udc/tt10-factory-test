`default_nettype none
`timescale 1ns / 1ps

module tb ();

    // Dump signals to a VCD file for waveform viewing
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
    end

    // Wires for inputs and outputs
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

`ifdef GL_TEST
    wire VPWR = 1'b1;
    wire VGND = 1'b0;
`endif

    // Instantiate the device under test (DUT)
    tt_um_medication_reminder #(
        .MEM_DEPTH(16),
        .MEM_ADDR_WIDTH(4)
    ) dut (
`ifdef GL_TEST
        .VPWR(VPWR),
        .VGND(VGND),
`endif
        .clk    (clk),
        .rst_n  (rst_n),
        .ena    (ena),
        .ui_in  (ui_in),
        .uo_out (uo_out),
        .uio_in (uio_in),
        .uio_out(uio_out),
        .uio_oe (uio_oe)
    );

endmodule
