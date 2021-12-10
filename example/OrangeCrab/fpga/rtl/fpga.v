module fpga #(
    parameter TARGET = "LATTICE"
)
(
    input              clk48,
    output reg         rgb_led0_r,
    output reg         rgb_led0_g,
    output reg         rgb_led0_b,

    input              rmii_50m,

    output             test
/*    output wire        eth_clocks_tx,
    input  wire        eth_clocks_rx,
    output wire        eth_rst_n,
    input  wire        eth_rx_ctl,
    input  wire [3:0]  eth_rx_data,
    output wire        eth_tx_ctl,
    output wire [3:0]  eth_tx_data,
    output             eth_mdc,
    inout              eth_mdio*/
);

wire sys_clk;

//assign test = sys_clk;

ODDRX1F ODDRX1F(
	.D0(1'd1),
	.D1(1'd0),
	.SCLK(clk48),
	.Q(test)
);


localparam MAX = 45_000_000;
localparam WIDTH = $clog2(MAX);

assign rgb_led0_r = 1;
assign rgb_led0_b = 1;

wire rst;

// Reset Generator
rst_gen rst_inst (.clk_i(clk48), .rst_i(1'b0), .rst_o(rst));

reg  [WIDTH-1:0] cpt_s;
wire [WIDTH-1:0] cpt_next_s = cpt_s + 1'b1;

// Blink Functionality
wire end_s = cpt_s == MAX-1;

always @(posedge sys_clk) begin
    cpt_s <= (rst || end_s) ? {WIDTH{1'b0}} : cpt_next_s;
    if (rst) begin
        rgb_led0_g <= 1'b0;
    end else if (end_s) begin
        rgb_led0_g <= ~rgb_led0_g;
    end
end

assign eth_rst_n = 1;

wire clkfb;
(* FREQUENCY_PIN_CLKI="48" *)
(* FREQUENCY_PIN_CLKOP="90" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(8),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(7),
        .CLKOP_CPHASE(3),
        .CLKOP_FPHASE(0),
        .FEEDBK_PATH("INT_OP"),
        .CLKFB_DIV(15)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clk48),
        .CLKOP(sys_clk),
        .CLKFB(clkfb),
        .CLKINTFB(clkfb),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);
/*
wire clkfb;
(* FREQUENCY_PIN_CLKI="25" *)
(* FREQUENCY_PIN_CLKOP="125" *)
(* FREQUENCY_PIN_CLKOS="125" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
    .PLLRST_ENA("DISABLED"),
    .INTFB_WAKE("DISABLED"),
    .STDBY_ENABLE("DISABLED"),
    .DPHASE_SOURCE("DISABLED"),
    .OUTDIVIDER_MUXA("DIVA"),
    .OUTDIVIDER_MUXB("DIVB"),
    .OUTDIVIDER_MUXC("DIVC"),
    .OUTDIVIDER_MUXD("DIVD"),
    .CLKI_DIV(1),
    .CLKOP_ENABLE("ENABLED"),
    .CLKOP_DIV(5),
    .CLKOP_CPHASE(2),
    .CLKOP_FPHASE(0),
    .CLKOS_ENABLE("ENABLED"),
    .CLKOS_DIV(5),
    .CLKOS_CPHASE(3),
    .CLKOS_FPHASE(2),
    .FEEDBK_PATH("INT_OP"),
    .CLKFB_DIV(5)
)
pll_i (
    .RST(1'b0),
    .STDBY(1'b0),
    .CLKI(clk48),
    .CLKOP(clk),
    .CLKOS(clk90),
    .CLKFB(clkfb),
    .CLKINTFB(clkfb),
    .PHASESEL0(1'b0),
    .PHASESEL1(1'b0),
    .PHASEDIR(1'b1),
    .PHASESTEP(1'b1),
    .PHASELOADREG(1'b1),
    .PLLWAKESYNC(1'b0),
    .ENCLKOP(1'b0),
    .LOCK(locked)
);*/
/*
fpga_core #(
    .TARGET(TARGET),
    .USE_CLK90("FALSE")
) ethCore0
(
    .rst(rst),
    .clk(clk),
    .clk90(clk90),	
    .phy0_tx_clk(eth_clocks_tx),
    .phy0_rx_clk(eth_clocks_rx),
    .phy0_rx_ctl(eth_rx_ctl),
    .phy0_rxd(eth_rx_data),
    .phy0_tx_ctl(eth_tx_ctl),
    .phy0_txd(eth_tx_data),
    .phy0_mdc(eth_mdc),
    .phy0_mdio(eth_mdio)
);
*/
endmodule
