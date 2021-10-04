//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
`ifndef CYCLONE
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] VIDEO_ARX,
	output  [7:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,

	

	output        LED_USER,  // 1 - ON, 0 - OFF.

	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
`else
	input         CLK_50M,
	output        LED_USER,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_CLOCK, //RELOADED
	output        VGA_BLANK = 1'b1, //RELOADED
	output        AUDSG_L,
	output        AUDSG_R,
   input         AUDIO_IN,
	
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,

	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,
	
	inout         PS2_CLK,
	inout         PS2_DAT,
`ifndef JOYDC
	output        JOY_CLK,
	output        JOY_LOAD,
	input         JOY_DATA,
	output        JOY_SELECT,
`else
	input	wire [5:0]JOYSTICK1,
	input	wire [5:0]JOYSTICK2,
	output        JOY_SELECT = 1'b1,
`endif	
	output        MCLK,
	output        SCLK,
	output        LRCLK,
	output        SDIN,
	output        STM_RST = 1'b0
`endif	
);

///////// Default values for ports not used in this core /////////

assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
//assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

//assign VGA_SL = 0;
assign VGA_F1 = 0;

//assign AUDIO_S = 0;
//assign AUDIO_L = 0;
//assign AUDIO_R = 0;
//assign AUDIO_MIX = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

assign VIDEO_ARX = status[5] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[5] ? 8'd9  : 8'd3; 

`include "build_id.v" 
localparam CONF_STR = {
	"Lynx48;;",
	"-;",
	"O5,Aspect ratio,4:3,16:9;",
   "O12,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%;",
	"-;",
	"O34,Machine,Lynx 48K,Lynx 96k,96k Scorpion;",
	"-;",
	"OD,Joysticks Swap,No,Yes;",
   "T0,Reset;",
	"R0,Reset and close OSD;",
	"V,v",`BUILD_DATE 
};

`ifndef CYCLONE
wire forced_scandoubler;
`else
wire        forced_scandoubler=host_scandoubler; //Negado = VGA x defecto.
`endif

wire [ 1:0] buttons;
wire [31:0] status;
wire [ 1:0] mode = status[4:3];
wire [ 1:0] old_mode;



//Keyboard Ps2
wire [1:0] ps2 = {PS2_DAT,PS2_CLK};
`ifndef JOYDC
wire [15:0]joystick_0;
wire [15:0]joystick_1;
`else
wire  [4:0] joystick_0 = ~JOYSTICK1[4:0];
wire  [4:0] joystick_1 = ~JOYSTICK2[4:0];
`endif

wire [5:0] joy_0 = status[13] ? joystick_1[5:0] : joystick_0[5:0];
wire [5:0] joy_1 = status[13] ? joystick_0[5:0] : joystick_1[5:0];

`ifndef CYCLONE
hps_io #(.STRLEN($size(CONF_STR)>>3), .PS2DIV(1103)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),

	.conf_str(CONF_STR),
	.forced_scandoubler(forced_scandoubler),

	.buttons(buttons),
	.status(status),
	.status_menumask({status[5]}),
	  //Keyboard Ps2
   .ps2_kbd_clk_out(ps2[0]),
   .ps2_kbd_data_out(ps2[1]),
	.joystick_0 (joystick_0),
	.joystick_1 (joystick_1)
	);
`else
wire [7:0]R_OSD,G_OSD,B_OSD;
wire host_scandoubler;
wire [7:0]R_IN = ~(HBlank | VBlank) ? {video[8:6],3'b000} : 0;
wire [7:0]G_IN = ~(HBlank | VBlank) ? {video[5:3],3'b000} : 0;
wire [7:0]B_IN = ~(HBlank | VBlank) ? {video[2:0],3'b000} : 0;
assign VGA_CLOCK = CLK_VIDEO;

data_io data_io
(
	.clk(clk_sys),
	.CLOCK_50(CLK_50M), //Para modulos de I2s y Joystick
	
	.debug(),
	
	.reset_n(pll_locked),

	.vga_hsync(~hsync),
	.vga_vsync(~vsync),
	
	.red_i(R_IN),//{r,{3{i & r}}}),
	.green_i(G_IN),//{g,{3{i & g}}}),
	.blue_i(B_IN),//{b,{3{i & b}}}),
	.red_o(R_OSD),
	.green_o(G_OSD),
	.blue_o(B_OSD),
	
	.ps2k_clk_in(PS2_CLK),
	.ps2k_dat_in(PS2_DAT),
	.ps2_key(ps2_key),
	.host_scandoubler_disable(host_scandoubler),
	
`ifndef JOYDC
	.JOY_CLK(JOY_CLK),
	.JOY_LOAD(JOY_LOAD),
	.JOY_DATA(JOY_DATA),
	.JOY_SELECT(JOY_SELECT),
	.joy1(joystick_0),
	.joy2(joystick_1),
`endif
	.dac_MCLK(MCLK),
	.dac_LRCK(LRCLK),
	.dac_SCLK(SCLK),
	.dac_SDIN(SDIN),
	.sigma_L(AUDSG_L),
	.sigma_R(AUDSG_R),
	.L_data(AUDIO_L),
	.R_data(AUDIO_R),
	
	.spi_miso(SD_MISO),
	.spi_mosi(SD_MOSI),
	.spi_clk(SD_SCK),
	.spi_cs(SD_CS),

	.img_mounted(img_mounted),
	.img_size(img_size),

	.status(status),
	
	.ioctl_ce(1'b1),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_file_ext()
);
`endif


///////////////////////   CLOCKS   ///////////////////////////////

wire clk_sys;
wire pll_locked;

pll pll
(
	.inclk0(CLK_50M),
	.areset(0),
	.c0(clk_sys),
	.c1(clk_sdram),
	.c2(clk_sdram_o),
	.locked(pll_locked)
);


always @(posedge clk_sys) begin
	old_mode <= mode;
	reset <= (!pll_locked | status[0] | buttons[1] | old_mode != mode);
end

//////////////////////////////////////////////////////////////////

wire [1:0] col = status[4:3];

wire HBlank;
wire HSync;
wire VBlank;
wire VSync;
wire [8:0] video;

lynx48 lynx48	
(
	.clock    (clk_sys),
	.reset_osd(~reset),
	.led      (LED_USER),

	.hSync    (HSync  ),
	.vSync    (VSync  ),
	.vBlank   (VBlank ),
	.hBlank   (HBlank ),
	.crtcDe   (crtcDe ),
	.rgb      (video  ),
	
	.ps2      (ps2    ),
	.joy_0    (~{1'b0,1'b0,joy_0[4],1'b0,joy_0[0],joy_0[1],joy_0[2],joy_0[3]} ),
	.joy_1    (~{1'b0,1'b0,joy_1[4],1'b0,joy_1[0],joy_1[1],joy_1[2],joy_1[3]} ),
	
	.audio    (AUDIO_L),
	.ear      (ear   ),
	
	
	.ce_pix   (ce_pix ),
	.mode     (mode)
);


assign AUDIO_R = AUDIO_L;
assign CLK_VIDEO = clk_sys;




wire [1:0] scale = status[2:1];
assign VGA_SL = scale ; //{scale == 3, scale == 2};
//assign VGA_SL = 0;

video_mixer #(448, 0, 0) mixer
(
		  
        .clk_vid(CLK_VIDEO),

        .ce_pix(ce_pix),
        .ce_pix_out(CE_PIXEL),

        .hq2x(scale == 1),
        .scanlines(0),
        .scandoubler (scale || forced_scandoubler),
		
		`ifndef CYCLONE
        .R({video[8:6],video[8]}), 
        .G({video[5:3],video[5]}), 
        .B({video[2:0],video[2]}),
		  .VGA_VS(VGA_VS),
        .VGA_HS(VGA_HS),
		`else
		.R(R_OSD),
		.G(G_OSD),
		.B(B_OSD),
		.VGA_DE(),
		.VGA_HS(hsync_o),
		.VGA_VS(vsync_o),
		`endif
		
        .mono(0),

        .HSync(HSync),
        .VSync(VSync),
        .HBlank(HBlank),
        .VBlank(VBlank),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_DE(VGA_DE)
);

`ifdef CYCLONE
reg hsync_o, vsync_o, csync_o, csync_en;

csync csync_gen (.clk(CLK_VIDEO), .hsync(hsync_o), .vsync(vsync_o), .csync(csync_o));

assign csync_en = !(scale || forced_scandoubler);
assign VGA_VS = csync_en ? 1'b1     : ~vsync_o;
assign VGA_HS = csync_en ? ~csync_o : ~hsync_o;

	//assign VGA_VS = (VGA_EN | SW[3]) ? 1'bZ      : csync_en ? 1'b1 : ~vs1;
	//assign VGA_HS = (VGA_EN | SW[3]) ? 1'bZ      : csync_en ? ~cs1 : ~hs1;

`endif

ssdram #(96) ssdram
(
  .clock_i    (clk_sdram),
  .reset_i    (reset),
  .refresh_i  (1'b1),
  //
  .addr_i     (ram_addr),
  .data_i     (ram_data_i),
  .data_o     (ram_data_o),
  .cs_i       (ram_cs_i),
  .oe_i       (ram_oe_i),
  .we_i       (ram_we_i),
  //
  
  .mem_cke_o  (SDRAM_CKE),
  .mem_cs_n_o (SDRAM_nCS),
  .mem_ras_n_o(SDRAM_nRAS),
  .mem_cas_n_o(SDRAM_nCAS),
  .mem_we_n_o (SDRAM_nWE),
  .mem_udq_o  (SDRAM_DQMH),
  .mem_ldq_o  (SDRAM_DQML),
  .mem_ba_o   (SDRAM_BA),
  .mem_addr_o (SDRAM_A),
  .mem_data_io(SDRAM_DQ)
  
);
assign SDRAM_CLK = clk_sdram_o;


/////////  EAR added by Fernando Mosquera
wire ear = ~AUDIO_IN;
//assign ear = tape_adc_act & tape_adc;

ltc2308_tape ltc2308_tape
(
  .clk(CLK_50M),
  .ADC_BUS(ADC_BUS),
  .dout(tape_adc),
  .active(tape_adc_act)
);
/////////////////////////


endmodule
