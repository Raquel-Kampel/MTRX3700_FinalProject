// File digital_cam_impl1/top_level.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2017 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

// cristinel ababei; Jan.29.2015; CopyLeft (CL);
// code name: "digital cam implementation #1";
// project done using Quartus II 13.1 and tested on DE2-115;
//
// this design basically connects a CMOS camera (OV7670 module) to
// DE2-115 board; video frames are picked up from camera, buffered
// on the FPGA (using embedded RAM), and displayed on the VGA monitor,
// which is also connected to the board; clock signals generated
// inside FPGA using ALTPLL's that take as input the board's 50MHz signal
// from on-board oscillator; 
//
// this whole project is an adaptation of Mike Field's original implementation 
// that can be found here:
// http://hamsterworks.co.nz/mediawiki/index.php/OV7670_camera
// no timescale needed

module top_level(
  // ~ CAM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  input wire        clk_50,
  input wire        btn_resend,
  output wire       led_config_finished,
  output wire       vga_hsync,
  output wire       vga_vsync,
  output wire [7:0] vga_r,
  output wire [7:0] vga_g,
  output wire [7:0] vga_b,
  output wire       vga_blank_N,
  output wire       vga_sync_N,
  output wire       vga_CLK,
  input wire        ov7670_pclk,
  output wire       ov7670_xclk,
  input wire        ov7670_vsync,
  input wire        ov7670_href,
  input wire  [7:0] ov7670_data,
  output wire       ov7670_sioc,
  inout wire        ov7670_siod,
  output wire       ov7670_pwdn,
  output wire       ov7670_reset,

  // ~ MIC ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output 	      I2C_SCLK,
  inout 	      I2C_SDAT,
  output  [6:0] HEX0,
  output  [6:0] HEX1,
  output  [6:0] HEX2,
  output  [6:0] HEX3,
  output  [6:0] HEX6,
  output  [6:0] HEX7,
  input 		    AUD_ADCDAT,
  input         AUD_BCLK,
  output        AUD_XCK,
  input         AUD_ADCLRCK,

  // ~ IR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  input         IRDA_RXD,         

  // ~ PERIPHERALS ~~~~~~~~~~~~~~~~~~~~~~
  output wire [17:0] LEDR,
  output wire [7:1]  LEDG
);

// ~ Reset ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
logic reset;
assign resend =  ~btn_resend;

// ~ DISPLAY ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// ~ IR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
logic [7:0] IR_button;

IR_top_level u_IR_top_level (
  .resend(reset),
  .clk_50(clk_50),
  .IRDA_RXD(IRDA_RXD),
  .IR_button(IR_button));

// ~ AUDIO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
logic [3:0] mapped_value;  // 4-bit value between 1 and 16
logic [1:0] speed = 1;

// mic_top_level u_mic_top_level (
//     // Pins
//     .CLOCK_50(clk_50),
//     .resend(resend),
//     .I2C_SCLK(I2C_SCLK),
//     .I2C_SDAT(I2C_SDAT),
//     .AUD_ADCDAT(AUD_ADCDAT),
//     .AUD_BCLK(AUD_BCLK),
//     .AUD_XCK(AUD_XCK),
//     .AUD_ADCLRCK(AUD_ADCLRCK),
//     .mapped_value(mapped_value),
//     .speed(speed));

// ~ CAMERA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
wire clk_50_camera;
wire clk_25_vga;
wire wren;
wire resend;
wire nBlank;
wire vSync;

wire [16:0] wraddress;
wire [11:0] wrdata;
wire [16:0] rdaddress;
wire [11:0] rddata;

wire [7:0] red; wire [7:0] green; wire [7:0] blue;
wire [7:0] red_O; wire [7:0] green_O; wire [7:0] blue_O;

wire activeArea;
wire is_orange;
wire orange_detected;
logic [2:0] direction;


assign vga_r = //red_O[7:0];
assign vga_g = //green_O[7:0];
assign vga_b = //blue_O[7:0];

my_altpll Inst_vga_pll(
  .inclk0(clk_50),
  .c0(clk_50_camera),
  .c1(clk_25_vga));

// take the inverted push button because KEY0 on DE2-115 board generates
// a signal 111000111; with 1 with not pressed and 0 when pressed/pushed;
assign vga_vsync = vSync;
assign vga_blank_N = nBlank;

VGA Inst_VGA (
  .CLK25(clk_25_vga),
  .clkout(vga_CLK),
  .Hsync(vga_hsync),
  .Vsync(vSync),
  .Nblank(nBlank),
  .Nsync(vga_sync_N),
  .activeArea(activeArea));

ov7670_controller Inst_ov7670_controller (
  .clk(clk_50_camera),
  .resend(resend),
  .config_finished(led_config_finished),
  .sioc(ov7670_sioc),
  .siod(ov7670_siod),
  .reset(ov7670_reset),
  .pwdn(ov7670_pwdn),
  .xclk(ov7670_xclk));

ov7670_capture Inst_ov7670_capture (
  .pclk(ov7670_pclk),
  .vsync(ov7670_vsync),
  .href(ov7670_href),
  .d(ov7670_data),
  .addr(wraddress),
  .dout(wrdata),
  .we(wren));

frame_buffer Inst_frame_buffer (
  .rdaddress(rdaddress),
  .rdclock(clk_25_vga),
  .q(rddata),
  .wrclock(ov7670_pclk),
  .wraddress(wraddress[16:0]),
  .data(wrdata),
  .wren(wren));

RGB Inst_RGB (
  .Din(rddata),
  .Nblank(activeArea),
  .R(red),
  .G(green),
  .B(blue));

Address_Generator Inst_Address_Generator (
  .CLK25(clk_25_vga),
  .enable(activeArea),
  .vsync(vSync),
  .address(rdaddress));

target_finder get_orange (
  .clk(clk_25_vga),                // Clock input
  .rst_n(resend),              // Active-low reset
  .red_in(red),           // red pixels
  .green_in(green),         // green pixels
  .blue_in(blue),          // blue pixels
  .red_out(red_O),           // red pixels
  .green_out(green_O),         // green pixels
  .blue_out(blue_O),          // blue pixels    
  .is_orange(is_orange));

classification classifier (
  .clk(clk_25_vga),
  .red(red),
  .green(green),
  .blue(blue),
  .HREF(vga_hsync),
  .fast(fast),
  .is_orange(is_orange),
  .direction(direction),
  .orangeDetected(orange_detected));

FSM u_FSM (
  .clk_50(clk_50),
  .IR_button(IR_button),
  .CAM_direction(direction),
  .speed(speed),
  .orange_detected(orange_detected),
  .reset(reset),
  .state(),
  .CAM_state(),
  .drive_state(),
  .HEX7(HEX7),
  .HEX6(HEX6));

endmodule