`default_nettype none
`timescale 1ns / 1ps

/* This testbench instantiates the module and makes convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Declare the wires and regs
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // For gate-level simulations (if applicable):
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate your DUT (Design Under Test)
  tt_um_medication_reminder user_project (

      // Include power ports for gate-level tests if necessary:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      // Connect the inputs/outputs to the testbench signals
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // Enable signal
      .clk    (clk),      // Clock signal
      .rst_n  (rst_n)     // Active-low reset signal
  );

endmodule
