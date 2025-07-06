//
// PCILeech Buffered Communication Core for either:
//   - FT601 USB3.
//   - FPGA RMII ETHERNET.
//
//
// (c) Ulf Frisk, 2019-2024
// Author: Ulf Frisk, pcileech@frizk.net
//

`timescale 1ns / 1ps
//`define ENABLE_ETH
`define ENABLE_FT601

module pcileech_com (
    // SYS
    input               clk,                // 100MHz SYSTEM CLK
    input               clk_com,            // COMMUNICATION CORE CLK
    input               rst,
    output              led_state_txdata,
    input               led_state_invert,

    // TO/FROM FIFO
    IfComToFifo.mp_com  dfifo,

`ifdef ENABLE_FT601
    // FT601
    inout   [31:0]      ft601_data,
    output  [3:0]       ft601_be,
    input               ft601_rxf_n,
    input               ft601_txe_n,
    output              ft601_wr_n,
    output              ft601_siwu_n,
    output              ft601_rd_n,
    output              ft601_oe_n
`endif /* ENABLE_FT601 */    
`ifdef ENABLE_ETH
    // ETH
    output              eth_clk50,
    output              eth_rst_n,
    input   [1:0]       eth_rx_data,
    input               eth_crs_dv,
    output              eth_tx_en,
    output  [1:0]       eth_tx_data,
    output              eth_mdc,
    inout               eth_mdio,
    input               eth_rx_err,
    input   [31:0]      eth_cfg_static_addr,
    input               eth_cfg_static_force,
    input   [15:0]      eth_cfg_port,
    output              eth_led_state_red,
    output              eth_led_state_green
`endif /* ENABLE_ETH */
    );

    // DRP Addresses (Big Endian)
    localparam    BAR0_LOW                <= 9'h0007; // 15:0
    localparam    BAR0_HIGH               <= 9'h0008; // 15:0
    localparam    BAR1_LOW                <= 9'h0009; // 15:0
    localparam    BAR1_HIGH               <= 9'h000a; // 15:0
    localparam    BAR2_LOW                <= 9'h000b; // 15:0
    localparam    BAR2_HIGH               <= 9'h000c; // 15:0
    localparam    BAR3_LOW                <= 9'h000d; // 15:0
    localparam    BAR3_HIGH               <= 9'h000e; // 15:0
    localparam    BAR4_LOW                <= 9'h000f; // 15:0
    localparam    BAR4_HIGH               <= 9'h0010; // 15:0
    localparam    BAR5_LOW                <= 9'h0011; // 15:0
    localparam    BAR5_HIGH               <= 9'h0012; // 15:0
    localparam    EXP_ROM_LOW             <= 9'h0013; // 15:0
    localparam    EXP_ROM_HIGH            <= 9'h0014; // 15:0
    localparam    CAP_PTR                 <= 9'h0015; // 7:0
    localparam    CARDBUS_PTR_LOW            <=9'h0016; // 15:0
    localparam    CARDBUS_PTR_HIGH            <=9'h0017; // 15:0
    localparam    CLASS_CODE_LOW            <=9'0018; // 15:0
    localparam    CLASS_CODE_HIGH            <=0'0019; // 7:0
    localparam    INTX_IMPL                <= 9'h0019; // 8

     // PCIe Capability Parameters
    localparam    CPL_TIMEOUT_DISABLE_SUPP   <=9'h0019; // 9
    localparam    CLP_TIMEOUT_RANGES_SUPP    <=9'h0019; // 13:10
    localparam    DEV_CAP2_ARI_FOWARD_SUPP    <=9'h0019; // 14
    localparam    DEV_CAP2_ATOMICOP_ROUTING_SUPP    <=9'h0019; // 15
    localparam    DEV_CAP2_ATOMICOP32_COMPL_SUPP    <=9'h001a; // 0
    localparam    DEV_CAP2_ATOMICOP64_COMPL_SUPP    <=9'h001a; // 1
    localparam    DEV_CAP2_CAS128_COMPL_SUPP        <=9'h001a; // 2
    localparam    DEV_CAP2_NO_RO_EN_PRPR_PASSING    <=9'h001a; // 3
    localparam    DEV_CAP2_LTR_MECH_SUPP            <=9'h001a; // 4
    localparam    DEV_CAP2_TPH__COMPL_SUPP          <=9'h001a; // 6:5
    localparam    DEV_CAP2_EXT_FMT_FIELD_SUPP       <=9'h001a; // 7
    localparam    DEV_CAP2_ENDEND_TLP_PREFIX_SUPP   <=9'h001a; // 8
    localparam    DEV_CAP2_MAX_ENDEND_TLP_PREFIXES    <=9'h001a; // 10:9
    localparam    ENDEND_TLP_PREFIX_FOWARD_SUPP        <=9'h001a; // 11
    localparam    DEV_CAP_EN_SLOT_PWR_LIMIT_SCALE    <=9'h001a; // 12
    localparam    DEV_CAP_EN_SLOT_PWR_LIMIT_VALUE    <=9'h001a; // 13
    localparam    DEV_CAP_ENDPOINT_L0S_LATENCY        <=9'h001b; // 2:0
    localparam    DEV_CAP_ENDPOINT_L1s_LATENCY        <=9'h001b; // 5:3
    localparam    DEV_CAP_EXT_TAG_SUPP                <=9'h001b; // 6
    localparam    DEV_CAP_FUNCTION_LVL_RST_CAPABLE    <=9'h001b; // 7
    localparam    DEV_CAP_MAX_PAYLOAD_SUPP            <=9'h001b; // 10:8
    localparam    DEV_CAP_PHANTOM_FUNCTIONS_SUPP      <=9'h001b; // 12:11
    localparam    DEV_CAP_ROLE_BASED_ERROR            <=9'h001b; // 13
   
localparam DEV_CAP_RSVD_14_12         = 9'h001b;    // [14:12]
localparam DEV_CAP_RSVD_17_16         = 9'h001c;    // [17:16]
localparam DEV_CONTROL_AUX_POWER_SUPP = 9'h001c;    // [8]
localparam DEV_CONTROL_EXT_TAG_DEFAULT = 9'h001c;    // [9]

// Link Parameters
localparam LINK_CAP_ASPM_SUPPORT      = 9'h023;    // [13:12]
localparam LINK_CAP_L0S_EXIT_LATENCY  = 9'h024;    // [2:0]
localparam LINK_CAP_L1_EXIT_LATENCY   = 9'h024;    // [5:3]
localparam LINK_CAP_MAX_LINK_SPEED    = 9'h025;    // [3:0]
localparam LINK_CAP_MAX_LINK_WIDTH    = 9'h025;    // [9:4]

// MSI/MSI-X Parameters
localparam MSI_BASE_PTR               = 9'h027;    // [7:0]
localparam MSI_CAP_64_BIT_ADDR_CAPABLE= 9'h027;    // [8]
localparam MSI_CAP_MULTIMSGCAP       = 9'h028;    // [2:0]
localparam MSI_CAP_MULTIMSG_EXTENSION= 9'h028;    // [4:3]
localparam MSI_CAP_ID                = 9'h028;    // [15:8]

// Power Management Parameters
localparam PM_BASE_PTR               = 9'h033;    // [7:0]
localparam PM_CAP_AUXCURRENT        = 9'h034;    // [2:0]
localparam PM_CAP_DSI               = 9'h034;    // [5]
localparam PM_CAP_D1SUPPORT         = 9'h034;    // [3]
localparam PM_CAP_D2SUPPORT         = 9'h034;    // [4]

// PCIe Extended Capabilities
localparam PCIE_CAP_CAPABILITY_ID    = 9'h031;    // [15:8]
localparam PCIE_CAP_CAPABILITY_VER   = 9'h031;    // [3:0]
localparam PCIE_CAP_DEVICE_PORT_TYPE = 9'h032;    // [7:4]
localparam PCIE_CAP_SLOT_IMPLEMENTED = 9'h033;    // [3]

// AER Capability Parameters
localparam AER_CAP_ECRC_CHECK_CAPABLE = 9'h000;    // [0]
localparam AER_CAP_ECRC_GEN_CAPABLE   = 9'h000;    // [1]
localparam AER_CAP_ID                 = 9'h001;    // [15:0]
localparam AER_CAP_VERSION            = 9'h001;    // [4:1]

// DSN Capability Parameters
localparam DSN_CAP_NEXTPTR           = 9'h01f;    // [11:0]
localparam DSN_CAP_ON                = 9'h01f;    // [12]
localparam DSN_CAP_VERSION           = 9'h020;    // [3:0]

// Virtual Channel Parameters
localparam VC_CAP_VERSION            = 9'h020;    // [3:0]
localparam VC_CAP_REJECT_SNOOP_TRANS = 9'h020;    // [4]



    // Initial Register Values (Little Endian)
    reg    BAR0_LOW_VALUE <= 16'h0000 // 0:15 -> 00000000
    reg    BAR0_HIGH_VALUE <=16'h0000 // 15:31 -> 00000000
    reg    BAR1_LOW_VALUE <= 16'h0000
    reg    BAR1_HIGH_VALUE <=16'h0000
    reg    BAR2_LOW_VALUE <= 16'h0000
    reg    BAR2_HIGH_VALUE <=16'h0000
    reg    BAR3_LOW_VALUE <= 16'h0000
    reg    BAR3_HIGH_VALUE <=16'h0000
    reg    BAR4_LOW_VALUE <= 16'h0000
    reg    BAR4_HIGH_VALUE <=16'h0000
    reg    BAR5_LOW_VALUE <= 16'h0000
    reg    BAR5_HIGH_VALUE <=16'h0000
    reg    CARDBUS_LOW_VALUE <= 16'h0000
    reg    CARDBUS_HIGH_VALUE <=16'h0000
    reg    EXP_ROM_LOW_VALUE <= 16'h0000
    reg    EXP_ROM_HIGH_VALUE <=16'h0000
    reg    CLASS_CODE_LOW_VALUE <= 16'h0000
    reg    CLASS_CODE_HIGH_VALUE <=16'h0000

    
    // ----------------------------------------------------------------------------
    // COMMUNICATION CORE INITIAL ON-BOARD DEFAULT RX-DATA
    // Sometimes there is a need to perform actions - such as setting DRP-related
    // values before the PCIe core is brought online. This is possible by specify
    // "virtual" COM-core initial transmitted values below.
    // ----------------------------------------------------------------------------
    
bit [63:0] initial_rx [5];  

initial begin
    // Set initial values to core parameters
    initial_rx[0] = {BAR0_LOW_VALUE, 16'hFFFF, BAR0_LOW, DRP_CMD};
    initial_rx[1] = {BAR0_HIGH_VALUE, 16'hFFFF, BAR0_HIGH, DRP_CMD};
    initial_rx[2] = 64'h00000000_00000000;
    initial_rx[3] = 64'h00000000_00000000;
    initial_rx[4] = 64'h00000000_00000000;

    // Bring the core online
    initial_rx[5] = 64'h00000003_80182377
end

        
    time tickcount64 = 0;
    always @ ( posedge clk )
        tickcount64 <= rst ? 0 : tickcount64 + 1;
        
    time tickcount64_com = 0;
    always @ ( posedge clk_com )
        tickcount64_com <= rst ? 0 : tickcount64_com + 1;
            
    wire        initial_rx_valid    = ~rst & (tickcount64 >= 16) & (tickcount64 < $size(initial_rx) + 16);
    wire [63:0] initial_rx_data     = initial_rx_valid ? initial_rx[tickcount64 - 16] : 64'h0;
    
    // ----------------------------------------------------------------------------
    // COMMUNICATION CORE RX DATA BELOW:
    // 1: convert 32-bit signal into 64-bit signal using logic.
    // 2: change clock domain from clk_com to clk using a very shallow fifo.
    //    due to previous 32->64 conversion this will be fine if: 2*clk_com < clk. 
    // ----------------------------------------------------------------------------
    
    wire [31:0] com_rx_data32;
    wire        com_rx_valid32;
    reg [63:0]  com_rx_data64;
    reg [1:0]   com_rx_valid64_dw;
    wire        com_rx_valid64 = com_rx_valid64_dw[0] & com_rx_valid64_dw[1];
    wire [63:0] com_rx_dout;
    wire        com_rx_valid;
   
    always @ ( posedge clk_com )
        if ( rst | (~com_rx_valid32 & com_rx_valid64_dw[0] & com_rx_valid64_dw[1]) )
            com_rx_valid64_dw <= 2'b00;
        else if ( com_rx_valid32 && (com_rx_data32 == 32'h66665555) && (com_rx_data64[31:0] == 32'h66665555) )
            // resync logic to allow the host to send resync data that will
            // allow bitstream to sync to proper 32->64-bit sequence in case
            // it should have happen to get out of sync at startup/shutdown.
            com_rx_valid64_dw <= 2'b00;
        else if ( com_rx_valid32 )
            begin
                com_rx_data64 <= (com_rx_data64 << 32) | com_rx_data32;
                com_rx_valid64_dw <= (com_rx_valid64_dw == 2'b01) ? 2'b11 : 2'b01;
            end
    
    fifo_64_64_clk2_comrx i_fifo_64_64_clk2_comrx(
        .rst            ( rst | (tickcount64_com<2) ),
        .wr_clk         ( clk_com                   ),
        .rd_clk         ( clk                       ),
        .din            ( com_rx_data64             ),
        .wr_en          ( com_rx_valid64            ),
        .rd_en          ( 1'b1                      ),
        .dout           ( com_rx_dout               ),
        .full           (                           ),
        .empty          (                           ),
        .valid          ( com_rx_valid              )
    );
    
    assign dfifo.com_dout = initial_rx_valid ? initial_rx_data : com_rx_dout;
    assign dfifo.com_dout_valid = initial_rx_valid | com_rx_valid;
    
    // ----------------------------------------------------------------------------
    // COMMUNICATION CORE TX DATA BELOW:
    // ----------------------------------------------------------------------------
       
    wire [31:0] core_din;
    wire        core_din_empty;
    wire        core_din_wr_en;
    wire        core_din_ready;
    
    wire [31:0] com_tx_data;
    wire        com_tx_wr_en;
    wire        com_tx_almost_full;
    wire        com_tx_prog_full;
    wire        com_tx_prog_empty;
    
    wire        out_buffer1_almost_full;

    assign dfifo.com_din_ready  = ~out_buffer1_almost_full;
    assign led_state_txdata     = com_tx_prog_full ^ led_state_invert;
    
    fifo_32_32_clk1_comtx i_fifo_32_32_clk2_comtx(
        .clk            ( clk_com                   ),
        .srst           ( rst                       ),
        .din            ( com_tx_data               ),
        .wr_en          ( com_tx_wr_en              ),
        .rd_en          ( core_din_ready            ),
        .dout           ( core_din                  ),
        .full           (                           ),
        .almost_full    ( com_tx_almost_full        ),
        .empty          ( core_din_empty            ),
        .prog_empty     ( com_tx_prog_empty         ),  // threshold = 3
        .prog_full      ( com_tx_prog_full          ),  // threshold = 6
        .valid          ( core_din_wr_en            )
    );
    fifo_256_32_clk2_comtx i_fifo_256_32_clk2_comtx(
        .rd_clk         ( clk_com                   ),
        .wr_clk         ( clk                       ),
        .rst            ( rst                       ),
        .din            ( dfifo.com_din             ),
        .wr_en          ( dfifo.com_din_wr_en       ),
        .rd_en          ( ~com_tx_almost_full       ),
        .dout           ( com_tx_data               ),
        .full           (                           ),
        .almost_full    ( out_buffer1_almost_full   ),
        .empty          (                           ),
        .valid          ( com_tx_wr_en              )
    );

    // ----------------------------------------------------
    // FT601 USB3 BELOW:
    // ----------------------------------------------------
`ifdef ENABLE_FT601
    
    pcileech_ft601 i_pcileech_ft601(
        // SYS
        .clk                ( clk_com               ),
        .rst                ( rst                   ),
        // TO/FROM FT601 PADS
        .FT601_DATA         ( ft601_data            ),
        .FT601_BE           ( ft601_be              ),
        .FT601_TXE_N        ( ft601_txe_n           ),
        .FT601_RXF_N        ( ft601_rxf_n           ),
        .FT601_SIWU_N       ( ft601_siwu_n          ),
        .FT601_WR_N         ( ft601_wr_n            ),
        .FT601_RD_N         ( ft601_rd_n            ),
        .FT601_OE_N         ( ft601_oe_n            ),
        // TO/FROM FIFO
        .dout               ( com_rx_data32         ),  // -> [31:0]
        .dout_valid         ( com_rx_valid32        ),  // ->        
        .din                ( core_din              ),  // <- [31:0]
        .din_wr_en          ( core_din_wr_en        ),  // <-
        .din_req_data       ( core_din_ready        )   // ->
    );
`endif /* ENABLE_FT601 */

    // ----------------------------------------------------
    // UDP Ethernet Below:
    // ----------------------------------------------------
`ifdef ENABLE_ETH

    pcileech_eth i_pcileech_eth(
        // SYS
        .clk                ( clk_com               ),
        .rst                ( rst                   ),
        // MAC/RMII
        .eth_clk50          ( eth_clk50             ),
        .eth_rst_n          ( eth_rst_n             ),
        .eth_crs_dv         ( eth_crs_dv            ),
        .eth_rx_data        ( eth_rx_data           ),
        .eth_rx_err         ( eth_rx_err            ),
        .eth_tx_en          ( eth_tx_en             ),
        .eth_tx_data        ( eth_tx_data           ),
        .eth_mdc            ( eth_mdc               ),
        .eth_mdio           ( eth_mdio              ),
        // CFG
        .cfg_static_addr    ( eth_cfg_static_addr   ),  // <- [31:0]
        .cfg_static_force   ( eth_cfg_static_force  ),  // <-
        .cfg_port           ( eth_cfg_port          ),  // <- [15:0]
        // State and Activity LEDs
        .led_state_red      ( eth_led_state_red     ),  // ->
        .led_state_green    ( eth_led_state_green   ),  // ->
        // TO/FROM FIFO
        .dout               ( com_rx_data32         ),  // -> [31:0]
        .dout_valid         ( com_rx_valid32        ),  // ->
        .din                ( core_din              ),  // <- [31:0]
        .din_empty          ( core_din_empty        ),  // <-
        .din_wr_en          ( core_din_wr_en        ),  // <-
        .din_ready          ( core_din_ready        )   // ->       
    );
`endif /* ENABLE_ETH */

endmodule
