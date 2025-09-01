/*
 * Copyright (c) 2025 Laurent Roro
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

/* === RANDOM STUFF === */

module nand_latch (
  input wire S,
  input wire R,
  output wire Q,
  output wire Qn
);
  wire q_int, qn_int;
  assign q_int  = ~(S & qn_int);
  assign qn_int = ~(R & q_int);
  assign Q = q_int;
  assign Qn = qn_int;
endmodule

module funky_rnd(
  input wire G, // generator state : 0 = random mode, 1 = freeze
  output wire R // output random value between 0 or 1
);
  nand_latch my_latch (
    .S(G), // !!! normally, S=R=0 is banned, but here I want Q to be random
    .R(G), // !!! so it's all good... maybe ? I don't know electronics enough.
    .Q(R),
    // .Qn(...)
  );
endmodule

// module pseudo_rnd(
//   input wire clk,
//   input wire rst,
//   output reg [7:0] R
// )
//   reg [7:0] lfsr;
//   wire feedback;

//   // Feedback polynomial: x^8 + x^6 + x^5 + x^4 + 1
//   assign feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

//   always @(posedge clk or posedge rst) begin
//     if (rst) begin
//       lfsr <= 8'h1;  // Non-zero seed
//     end else begin
//       lfsr <= {lfsr[6:0], feedback};
//     end
//   end

//   // Output current LFSR value as pseudo-random value
//   always @(*) begin
//     rand_val = lfsr;
//   end
// endmodule

/*  */

// ===================
// === MAIN MODULE ===
// ===================

// tt_um_SNPU stands for "Tiny Tapeout - Secret Nigon Processing Unit"
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

  // // TODO : initialize with P_stack=b'0_0000_0000_0011_1111
  // reg [17:0] P_stack; // a list of all Policy cards in the main stack (contains 6x 1 and 11x 0)
  // reg [5:0]  P_stack_N; // list length (5-bit integer)

  // reg [17:0] P_discard; // list of Policy cards in the discard pile
  // reg [5:0]  P_discard_N; // list length (5-bit integer)

  // reg [17:0] P_board; // list of Policy cards on the board
  // reg [5:0]  P_board_N; // list length (5-bit integer)

  // TODO :
  // OP_reset : reset the board
  // OP_discard :
  // OP_shuffle : merge P_discard with P_stack ; then shuffle P_stack

  // OP_role_distribution : for a given count of players

  // actions we need:
  // peak 3 cards
  // peak 2 cards
  // discard card #0 #1 or #2 from P_stack
  // play    card #0 #1 or #2 from P_stack

  // read

  // role distribution

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
endmodule
