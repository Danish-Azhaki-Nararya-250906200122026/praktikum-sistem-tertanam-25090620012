//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
//Date        : Sun Nov  8 17:37:27 2026
//Host        : WIN-THPHG8T68EP running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (Clk,
    led_tri_io,
    reset_rtl);
  input Clk;
  inout [15:0]led_tri_io;
  input reset_rtl;

  wire Clk;
  wire [0:0]led_tri_i_0;
  wire [1:1]led_tri_i_1;
  wire [10:10]led_tri_i_10;
  wire [11:11]led_tri_i_11;
  wire [12:12]led_tri_i_12;
  wire [13:13]led_tri_i_13;
  wire [14:14]led_tri_i_14;
  wire [15:15]led_tri_i_15;
  wire [2:2]led_tri_i_2;
  wire [3:3]led_tri_i_3;
  wire [4:4]led_tri_i_4;
  wire [5:5]led_tri_i_5;
  wire [6:6]led_tri_i_6;
  wire [7:7]led_tri_i_7;
  wire [8:8]led_tri_i_8;
  wire [9:9]led_tri_i_9;
  wire [0:0]led_tri_io_0;
  wire [1:1]led_tri_io_1;
  wire [10:10]led_tri_io_10;
  wire [11:11]led_tri_io_11;
  wire [12:12]led_tri_io_12;
  wire [13:13]led_tri_io_13;
  wire [14:14]led_tri_io_14;
  wire [15:15]led_tri_io_15;
  wire [2:2]led_tri_io_2;
  wire [3:3]led_tri_io_3;
  wire [4:4]led_tri_io_4;
  wire [5:5]led_tri_io_5;
  wire [6:6]led_tri_io_6;
  wire [7:7]led_tri_io_7;
  wire [8:8]led_tri_io_8;
  wire [9:9]led_tri_io_9;
  wire [0:0]led_tri_o_0;
  wire [1:1]led_tri_o_1;
  wire [10:10]led_tri_o_10;
  wire [11:11]led_tri_o_11;
  wire [12:12]led_tri_o_12;
  wire [13:13]led_tri_o_13;
  wire [14:14]led_tri_o_14;
  wire [15:15]led_tri_o_15;
  wire [2:2]led_tri_o_2;
  wire [3:3]led_tri_o_3;
  wire [4:4]led_tri_o_4;
  wire [5:5]led_tri_o_5;
  wire [6:6]led_tri_o_6;
  wire [7:7]led_tri_o_7;
  wire [8:8]led_tri_o_8;
  wire [9:9]led_tri_o_9;
  wire [0:0]led_tri_t_0;
  wire [1:1]led_tri_t_1;
  wire [10:10]led_tri_t_10;
  wire [11:11]led_tri_t_11;
  wire [12:12]led_tri_t_12;
  wire [13:13]led_tri_t_13;
  wire [14:14]led_tri_t_14;
  wire [15:15]led_tri_t_15;
  wire [2:2]led_tri_t_2;
  wire [3:3]led_tri_t_3;
  wire [4:4]led_tri_t_4;
  wire [5:5]led_tri_t_5;
  wire [6:6]led_tri_t_6;
  wire [7:7]led_tri_t_7;
  wire [8:8]led_tri_t_8;
  wire [9:9]led_tri_t_9;
  wire reset_rtl;

  design_1 design_1_i
       (.Clk(Clk),
        .led_tri_i({led_tri_i_15,led_tri_i_14,led_tri_i_13,led_tri_i_12,led_tri_i_11,led_tri_i_10,led_tri_i_9,led_tri_i_8,led_tri_i_7,led_tri_i_6,led_tri_i_5,led_tri_i_4,led_tri_i_3,led_tri_i_2,led_tri_i_1,led_tri_i_0}),
        .led_tri_o({led_tri_o_15,led_tri_o_14,led_tri_o_13,led_tri_o_12,led_tri_o_11,led_tri_o_10,led_tri_o_9,led_tri_o_8,led_tri_o_7,led_tri_o_6,led_tri_o_5,led_tri_o_4,led_tri_o_3,led_tri_o_2,led_tri_o_1,led_tri_o_0}),
        .led_tri_t({led_tri_t_15,led_tri_t_14,led_tri_t_13,led_tri_t_12,led_tri_t_11,led_tri_t_10,led_tri_t_9,led_tri_t_8,led_tri_t_7,led_tri_t_6,led_tri_t_5,led_tri_t_4,led_tri_t_3,led_tri_t_2,led_tri_t_1,led_tri_t_0}),
        .reset_rtl(reset_rtl));
  IOBUF led_tri_iobuf_0
       (.I(led_tri_o_0),
        .IO(led_tri_io[0]),
        .O(led_tri_i_0),
        .T(led_tri_t_0));
  IOBUF led_tri_iobuf_1
       (.I(led_tri_o_1),
        .IO(led_tri_io[1]),
        .O(led_tri_i_1),
        .T(led_tri_t_1));
  IOBUF led_tri_iobuf_10
       (.I(led_tri_o_10),
        .IO(led_tri_io[10]),
        .O(led_tri_i_10),
        .T(led_tri_t_10));
  IOBUF led_tri_iobuf_11
       (.I(led_tri_o_11),
        .IO(led_tri_io[11]),
        .O(led_tri_i_11),
        .T(led_tri_t_11));
  IOBUF led_tri_iobuf_12
       (.I(led_tri_o_12),
        .IO(led_tri_io[12]),
        .O(led_tri_i_12),
        .T(led_tri_t_12));
  IOBUF led_tri_iobuf_13
       (.I(led_tri_o_13),
        .IO(led_tri_io[13]),
        .O(led_tri_i_13),
        .T(led_tri_t_13));
  IOBUF led_tri_iobuf_14
       (.I(led_tri_o_14),
        .IO(led_tri_io[14]),
        .O(led_tri_i_14),
        .T(led_tri_t_14));
  IOBUF led_tri_iobuf_15
       (.I(led_tri_o_15),
        .IO(led_tri_io[15]),
        .O(led_tri_i_15),
        .T(led_tri_t_15));
  IOBUF led_tri_iobuf_2
       (.I(led_tri_o_2),
        .IO(led_tri_io[2]),
        .O(led_tri_i_2),
        .T(led_tri_t_2));
  IOBUF led_tri_iobuf_3
       (.I(led_tri_o_3),
        .IO(led_tri_io[3]),
        .O(led_tri_i_3),
        .T(led_tri_t_3));
  IOBUF led_tri_iobuf_4
       (.I(led_tri_o_4),
        .IO(led_tri_io[4]),
        .O(led_tri_i_4),
        .T(led_tri_t_4));
  IOBUF led_tri_iobuf_5
       (.I(led_tri_o_5),
        .IO(led_tri_io[5]),
        .O(led_tri_i_5),
        .T(led_tri_t_5));
  IOBUF led_tri_iobuf_6
       (.I(led_tri_o_6),
        .IO(led_tri_io[6]),
        .O(led_tri_i_6),
        .T(led_tri_t_6));
  IOBUF led_tri_iobuf_7
       (.I(led_tri_o_7),
        .IO(led_tri_io[7]),
        .O(led_tri_i_7),
        .T(led_tri_t_7));
  IOBUF led_tri_iobuf_8
       (.I(led_tri_o_8),
        .IO(led_tri_io[8]),
        .O(led_tri_i_8),
        .T(led_tri_t_8));
  IOBUF led_tri_iobuf_9
       (.I(led_tri_o_9),
        .IO(led_tri_io[9]),
        .O(led_tri_i_9),
        .T(led_tri_t_9));
endmodule
