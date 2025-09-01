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

  // board game state
  reg [16:0] policies; // 17 policy cards with 6x 0 and 11x 1.
  reg [5:0] N_stack;   // initialized to 17 : number of policies in the main stack
  reg [5:0] N_discard; // initialized to 0  : number of cards that are in the hand of a player
  // policies  : [ 0 1 1 0 1 1 1║0 1 0 1 1┊0 1 0 1 1 ]
  // N_stack   : ═══════════════╝         ┊           
  // N_discard :                └─────────┘           
  //              [STACK]        [DISCARD] [ BOARD ]

  // role distribution for game initialization
  reg [10:0] players_party;
  reg [10:0] players_nigonitude;

  // stored state for outputs
  reg [7:0] reg_uio
  reg [7:0] reg_uo

  wire [2:0] op_code;
  assign op_code = ui_in[7:5];  // Use the top 3 bits of A to determine the operation
  // always @(*) begin
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      policies  <= 17'b00000000000111111; // cf [board game state]
      N_stack   <= 17; // cf [board game state]
      N_discard <= 0 ; // cf [board game state]
      // players_party <= 0; // TODO
      // players_nigonitude<=0; // TODO
      reg_uio <=0 // TODO : I think we don't care
      reg_uo  <=0 // TODO : I think we don't care
    end else case (op_code)
      // 3'b000: uo_out = A + B;           // Addition
      // 3'b001: uo_out = A - B;           // Subtraction
      // 3'b010: uo_out = A & B;           // Bitwise AND
      // 3'b011: uo_out = A | B;           // Bitwise OR
      // 3'b100: uo_out = A ^ B;           // Bitwise XOR
      // 3'b101: uo_out = ~A;              // Bitwise NOT of A
      // 3'b110: uo_out = B;               // Pass through B
      // 3'b111: uo_out = A;               // Pass through A
      default: uo_out = 8'b00000000;
    endcase
  end

  // list of operations :
  // - OP_reset() : policies=00000000000111111, N_stack=17, N_hand=0, N_discard = 0
  // - OP_player_reset(player_count) : initialize player array to 000...01...1 and another array with 000...01, they will be shuffled together
  // - OP_player_get(index)
  // - OP_shuffle() : shuffles all bits in [0..(N_stack+N_discard)] ; might need to run multiple time to get an actual shuffle ; only works if N_hand==0
  // - OP_hand_display(index) : shows the card at N_stack-1-index
  // - OP_hand_discard(index) : shift all registers from N_stack-1-index etc...
  // - OP_hand_play(index)    : shift all registers from N_stack-1-index etc...
  // - OP_board_display() : outputs two 4 bit integers (how many ZEROS and how many ONES inside the BOARD section)

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};
endmodule
