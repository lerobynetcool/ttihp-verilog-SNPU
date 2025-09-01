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
  wire Qn_ignore;
  nand_latch my_latch (
    .S(G), // !!! normally, S=R=0 is banned, but here I want Q to be random
    .R(G), // !!! so it's all good... maybe ? I don't know electronics enough.
    .Q(R),
    .Qn(Qn_ignore)
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

  reg [16:0] policies; // 17 policy cards with 6x 0 and 11x 1.
  reg [5:0] N_stack;   // initialized to 17 : number of policies in the main stack
  reg [5:0] N_hand;    // initialized to 0  : number of cards that are in the hand of a player
  reg [5:0] N_discard; // initialized to 0  : number of cards that are in the hand of a player
  // N_hand    :          ┌─────┐                     
  // policies  : [ 0 1 1 0┊1 1 1║0 1 0 1 1┊0 1 0 1 1 ]
  // N_stack   : ═══════════════╝         ┊           
  // N_discard :                └─────────┘           
  //              [STACK] [HAND] [DISCARD] [ BOARD ]

  reg [10:0] players_party;
  reg [10:0] players_nigonitude;


  // list of operations :
  // - OP_reset() : policies=00000000000111111, N_stack=17, N_hand=0, N_discard = 0
  // - OP_player_reset(player_count) : initialize player array to 000...01...1 and another array with 000...01, they will be shuffled together
  // - OP_player_get(index)
  // - OP_shuffle() : shuffles all bits in [0..(N_stack+N_discard)] ; might need to run multiple time to get an actual shuffle ; only works if N_hand==0
  // - OP_hand_pick() : N_hand = 3
  // - OP_hand_discard(index) : shift all registers from N_stack-index etc...
  // - OP_hand_play(index)    : shift all registers from N_stack-index etc...
  // - OP_hand_display() : shows up to 3 cards encoded as [00 = POLICY_0; 11 = POLICY_1; 01 and 10 = NO_CARD]
  // - OP_board_display() : outputs two 4 bit integers (how many ZEROS and how many ONES inside the BOARD section)

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
endmodule
