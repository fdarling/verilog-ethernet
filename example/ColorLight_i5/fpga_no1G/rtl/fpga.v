module fpga #(
    parameter TARGET = "LATTICE"
)
(
    input              clk_i,
    output reg         led_o,

//    output             spi_flash_sck,
    output             spi_flash_mosi,
    input              spi_flash_miso,    
    output             spi_flash_cs,

    output wire        eth_clocks_tx,
    input  wire        eth_clocks_rx,
    output wire        eth_rst_n,
    input  wire        eth_rx_ctl,
    input  wire [3:0]  eth_rx_data,
    output wire        eth_tx_ctl,
    output wire [3:0]  eth_tx_data,
    output             eth_mdc,
    inout              eth_mdio//,

//    output [15:0]      dbg_out

);

USRMCLK USRMCLK(
	.USRMCLKI(spi_flash_sck),
	.USRMCLKTS(1'd0)
);


localparam MAX = 12_500_000;
localparam WIDTH = $clog2(MAX);

wire clk125;
wire clk_system;


wire rst;
// Reset Generator
rst_gen rst_inst (.clk_i(clk_system), .rst_i(1'b0), .rst_o(rst));


reg  [WIDTH-1:0] cpt_s;
wire [WIDTH-1:0] cpt_next_s = cpt_s + 1'b1;

// Blink Functionality
wire end_s = cpt_s == MAX-1;
/*
always @(posedge clk_i) begin
    cpt_s <= (rst || end_s) ? {WIDTH{1'b0}} : cpt_next_s;
    if (rst) begin
        led_o <= 1'b0;
    end else if (end_s) begin
        led_o <= ~led_o;
    end
end
*/
assign eth_rst_n = 1;

(* FREQUENCY_PIN_CLKI="25" *)
(* FREQUENCY_PIN_CLKOP="125" *)
(* FREQUENCY_PIN_CLKOS="89.2857" *)
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
    .CLKOS_DIV(7),
    .CLKOS_CPHASE(2),
    .CLKOS_FPHASE(0),
    .FEEDBK_PATH("CLKOP"),
    .CLKFB_DIV(5)
) 
pll_i (
    .RST(1'b0),
    .STDBY(1'b0),
    .CLKI(clk_i),
    .CLKOP(clk125),
    .CLKOS(clk_system),
    .CLKFB(clk125),
    .CLKINTFB(),
    .PHASESEL0(1'b0),
    .PHASESEL1(1'b0),
    .PHASEDIR(1'b1),
    .PHASESTEP(1'b1),
    .PHASELOADREG(1'b1),
    .PLLWAKESYNC(1'b0),
    .ENCLKOP(1'b0),
);


fpga_core #(
    .TARGET(TARGET),
    .USE_CLK90("FALSE")
) ethCore0
(
    .rst(rst),
    .clk125(clk125),
    .clk_system(clk_system),
    .clk25(clk_i),
    .clk90(clk90),	

    .spi_flash_sck(spi_flash_sck),
    .spi_flash_mosi(spi_flash_mosi),
    .spi_flash_miso(spi_flash_miso),
    .spi_flash_cs(spi_flash_cs), 

    .dbg_led (led_o),
//    .dbg_out (dbg_out),

    .phy0_tx_clk(eth_clocks_tx),
    .phy0_rx_clk(eth_clocks_rx),
    .phy0_rx_ctl(eth_rx_ctl),
    .phy0_rxd(eth_rx_data),
    .phy0_tx_ctl(eth_tx_ctl),
    .phy0_txd(eth_tx_data),
    .phy0_mdc(eth_mdc),
    .phy0_mdio(eth_mdio)
);

endmodule
