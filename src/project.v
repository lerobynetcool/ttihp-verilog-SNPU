/*
 * Copyright (c) 2025 Laurent Roro
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// type: nand2 
`timescale 1ns/10ps
`celldefine
module sg13g2_nand2_1 (Y, A, B);
	output Y;
	input A, B;

	// Function
	wire int_fwire_0;

	and (int_fwire_0, A, B);
	not (Y, int_fwire_0);

	// Timing
	specify
		(A => Y) = 0;
		(B => Y) = 0;
	endspecify
endmodule
`endcelldefine

// module nand_latch (
//   input wire S,
//   input wire R,
//   output wire Q,
//   output wire Qn
// );
//   wire q_int, qn_int;
//   assign q_int  = ~(S & qn_int);
//   assign qn_int = ~(R & q_int);
//   assign Q = q_int;
//   assign Qn = qn_int;
// endmodule

module nand_latch (
  input wire S,
  input wire R,
  output wire Q,
  output wire Qn
);
  sg13g2_nand2_1 Q_inst (.A(S), .B(Qn), .Y(Q));
  sg13g2_nand2_1 Qn_inst (.A(R), .B(Q), .Y(Qn));
endmodule

module funky_rnd(
  input wire G, // generator state : 0 = random mode, 1 = freeze
  output wire R // output random value between 0 or 1
);
  wire Qn_ignore;
  nand_latch my_latch (
    .S(G), // !!! normally, S=R=0 is banned, but here I want Q to be random
    .R(G), // !!! so it's all good... maybe ? I don't know electronics enough.
    .Q(R),
    .Qn(Qn_ignore)
  );
endmodule

module tt_um_SNPU (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);
  // assign uio_oe  = 0;
  assign uio_oe  = 1; // use io pins as outputs

  funky_rnd rnd00 (.G(ui_in[0]),.R(uo_out[0]));
  funky_rnd rnd01 (.G(ui_in[0]),.R(uo_out[1]));
  funky_rnd rnd02 (.G(ui_in[0]),.R(uo_out[2]));
  funky_rnd rnd03 (.G(ui_in[0]),.R(uo_out[3]));
  funky_rnd rnd04 (.G(ui_in[0]),.R(uo_out[4]));
  funky_rnd rnd05 (.G(ui_in[0]),.R(uo_out[5]));
  funky_rnd rnd06 (.G(ui_in[0]),.R(uo_out[6]));
  funky_rnd rnd07 (.G(ui_in[0]),.R(uo_out[7]));

  funky_rnd rnd10 (.G(ui_in[0]),.R(uio_out[0]));
  funky_rnd rnd11 (.G(ui_in[0]),.R(uio_out[1]));
  funky_rnd rnd12 (.G(ui_in[0]),.R(uio_out[2]));
  funky_rnd rnd13 (.G(ui_in[0]),.R(uio_out[3]));
  funky_rnd rnd14 (.G(ui_in[0]),.R(uio_out[4]));
  funky_rnd rnd15 (.G(ui_in[0]),.R(uio_out[5]));
  funky_rnd rnd16 (.G(ui_in[0]),.R(uio_out[6]));
  funky_rnd rnd17 (.G(ui_in[0]),.R(uio_out[7]));

  wire _unused = &{uio_in,clk,rst_n,ena, 1'b0};
endmodule
