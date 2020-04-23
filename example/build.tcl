# Project creation
create_project pandacam . -part xc7z020clg400-1

# Creating new block design
create_bd_design "pandacam"

# Adding ZYNQ-7000 Processing System
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 zynq_ps

# Congiguring PS
source ./zynq_config.tcl

# Add local repository with CSI2 IP-core
set_property ip_repo_paths [list \
  ../]                           \
[current_project]
update_ip_catalog 

# Add Clock Wizard to create 74.25 MHz pixel clock
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 px_clk_mmcm
set_property -dict [ list                    \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {74.25}  \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {148.5}  \
  CONFIG.CLKOUT2_USED               {true}   \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {742.5}  \
  CONFIG.CLKOUT3_USED               {true}   \
  CONFIG.NUM_OUT_CLKS               {3}      \
  CONFIG.USE_LOCKED                 {false}  \
  CONFIG.USE_RESET                  {false}] \
[get_bd_cells px_clk_mmcm]

# AXI4 to AXI3 converter for write port
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 memory_write_port_adapter
set_property -dict [ list \
  CONFIG.NUM_MI {1}]      \
[get_bd_cells memory_write_port_adapter]

# AXI4 to AXI3 converter for read port
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 memory_read_port_adapter
set_property -dict [ list \
  CONFIG.NUM_MI {1}]      \
[get_bd_cells memory_read_port_adapter]

# Interconnect from JTAG to other modules
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 csr_interconnect

# Reset for 200 MHz clock
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 ref_clk_rst
# Reset for 74.25 MHz clock
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 wr_clk_rst
# Reset for 148.5 MHz clock
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rd_clk_rst

# Create JTAG controller to CSR
create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag_axi

# HDMI Transmitter
create_bd_cell -type ip -vlnv hellgate202:user:hdmi_tx:1.0 hdmi_tx

# Add CSI2-RX IP-core
create_bd_cell -type ip -vlnv hellgate:user:csi2_2_lane_rx:1.0 csi2_2_lane_rx

# Frame buffer to increase px clock to 148.5 MHz
create_bd_cell -type ip -vlnv hellgate202:user:frame_buffer:1.0 frame_buffer
set_property -dict [ list       \
  CONFIG.START_ADDR {268435456} \
  CONFIG.FRAMES_AMOUNT {3}      \
  CONFIG.PX_WIDTH {10}          \
  CONFIG.TDATA_WIDTH {16}       \
  CONFIG.TDATA_WIDTH_B {2}]     \
[get_bd_cells frame_buffer]

# Just duplicates the values to RGB channels
create_bd_cell -type ip -vlnv hellgate:user:grayscale_to_rgb_adapter:1.0 rgb_converter

# Connecting clocks
# 200 MHz
connect_bd_net [get_bd_pins zynq_ps/FCLK_CLK0] [get_bd_pins px_clk_mmcm/clk_in1]
connect_bd_net [get_bd_pins zynq_ps/FCLK_CLK0] [get_bd_pins ref_clk_rst/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ps/FCLK_CLK0] [get_bd_pins csi2_2_lane_rx/ref_clk_i]
# 74.25 MHz
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins csi2_2_lane_rx/px_clk_i]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins wr_clk_rst/slowest_sync_clk]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins jtag_axi/aclk]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins frame_buffer/wr_clk_i]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins csr_interconnect/ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins csr_interconnect/S00_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins csr_interconnect/M00_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins csr_interconnect/M01_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins memory_write_port_adapter/ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins memory_write_port_adapter/S00_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins memory_write_port_adapter/M00_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out1] [get_bd_pins zynq_ps/S_AXI_HP0_ACLK]
#148.5 MHz
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins rd_clk_rst/slowest_sync_clk]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins frame_buffer/rd_clk_i]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins memory_read_port_adapter/ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins memory_read_port_adapter/S00_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins memory_read_port_adapter/M00_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins zynq_ps/S_AXI_HP1_ACLK]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins rgb_converter/clk_i]
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out2] [get_bd_pins hdmi_tx/px_clk_i]
#742.5 MHz
connect_bd_net [get_bd_pins px_clk_mmcm/clk_out3] [get_bd_pins hdmi_tx/tmds_clk_i]
# Connecting resets
connect_bd_net [get_bd_pins zynq_ps/FCLK_RESET0_N] [get_bd_pins ref_clk_rst/ext_reset_in]
connect_bd_net [get_bd_pins zynq_ps/FCLK_RESET0_N] [get_bd_pins wr_clk_rst/ext_reset_in]
connect_bd_net [get_bd_pins zynq_ps/FCLK_RESET0_N] [get_bd_pins rd_clk_rst/ext_reset_in]
connect_bd_net [get_bd_pins ref_clk_rst/peripheral_reset] [get_bd_pins csi2_2_lane_rx/ref_rst_i]
connect_bd_net [get_bd_pins wr_clk_rst/peripheral_reset] [get_bd_pins frame_buffer/wr_rst_i]
connect_bd_net [get_bd_pins wr_clk_rst/peripheral_reset] [get_bd_pins csi2_2_lane_rx/px_rst_i]
connect_bd_net [get_bd_pins wr_clk_rst/peripheral_aresetn] [get_bd_pins jtag_axi/aresetn]
connect_bd_net [get_bd_pins wr_clk_rst/interconnect_aresetn] [get_bd_pins csr_interconnect/ARESETN]
connect_bd_net [get_bd_pins wr_clk_rst/interconnect_aresetn] [get_bd_pins csr_interconnect/S00_ARESETN]
connect_bd_net [get_bd_pins wr_clk_rst/interconnect_aresetn] [get_bd_pins csr_interconnect/M00_ARESETN]
connect_bd_net [get_bd_pins wr_clk_rst/interconnect_aresetn] [get_bd_pins csr_interconnect/M01_ARESETN]
connect_bd_net [get_bd_pins wr_clk_rst/interconnect_aresetn] [get_bd_pins memory_write_port_adapter/ARESETN]
connect_bd_net [get_bd_pins wr_clk_rst/interconnect_aresetn] [get_bd_pins memory_write_port_adapter/S00_ARESETN]
connect_bd_net [get_bd_pins wr_clk_rst/interconnect_aresetn] [get_bd_pins memory_write_port_adapter/M00_ARESETN]
connect_bd_net [get_bd_pins rd_clk_rst/peripheral_reset] [get_bd_pins frame_buffer/rd_rst_i]
connect_bd_net [get_bd_pins rd_clk_rst/peripheral_reset] [get_bd_pins hdmi_tx/rst_i]
connect_bd_net [get_bd_pins rd_clk_rst/peripheral_reset] [get_bd_pins rgb_converter/rst_i]
connect_bd_net [get_bd_pins rd_clk_rst/interconnect_aresetn] [get_bd_pins memory_read_port_adapter/ARESETN]
connect_bd_net [get_bd_pins rd_clk_rst/interconnect_aresetn] [get_bd_pins memory_read_port_adapter/S00_ARESETN]
connect_bd_net [get_bd_pins rd_clk_rst/interconnect_aresetn] [get_bd_pins memory_read_port_adapter/M00_ARESETN]
# Connecting interfaces
connect_bd_intf_net [get_bd_intf_pins jtag_axi/M_AXI] [get_bd_intf_pins csr_interconnect/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins csr_interconnect/M00_AXI] [get_bd_intf_pins csi2_2_lane_rx/sccb_ctrl]
connect_bd_intf_net [get_bd_intf_pins csr_interconnect/M01_AXI] [get_bd_intf_pins csi2_2_lane_rx/csi2_csr]
connect_bd_intf_net [get_bd_intf_pins csi2_2_lane_rx/video] [get_bd_intf_pins frame_buffer/video_i]
connect_bd_intf_net [get_bd_intf_pins frame_buffer/video_o] [get_bd_intf_pins rgb_converter/video_i]
connect_bd_intf_net [get_bd_intf_pins rgb_converter/video_o] [get_bd_intf_pins hdmi_tx/video_i]
connect_bd_intf_net [get_bd_intf_pins frame_buffer/mem_wr] [get_bd_intf_pins memory_write_port_adapter/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins memory_write_port_adapter/M00_AXI] [get_bd_intf_pins zynq_ps/S_AXI_HP0]
connect_bd_intf_net [get_bd_intf_pins frame_buffer/mem_rd] [get_bd_intf_pins memory_read_port_adapter/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins memory_read_port_adapter/M00_AXI] [get_bd_intf_pins zynq_ps/S_AXI_HP1]
 
# Connecting output ports
create_bd_port -dir O cam_pwup_o
connect_bd_net [get_bd_ports cam_pwup_o] [get_bd_pins csi2_2_lane_rx/cam_pwup_o]
create_bd_port -dir I dphy_clk_n_i
connect_bd_net [get_bd_ports dphy_clk_n_i] [get_bd_pins csi2_2_lane_rx/dphy_clk_n_i]
create_bd_port -dir I dphy_clk_p_i
connect_bd_net [get_bd_ports dphy_clk_p_i] [get_bd_pins csi2_2_lane_rx/dphy_clk_p_i]
create_bd_port -dir I -from 1 -to 0 dphy_data_n_i
connect_bd_net [get_bd_ports dphy_data_n_i] [get_bd_pins csi2_2_lane_rx/dphy_data_n_i]
create_bd_port -dir I -from 1 -to 0 dphy_data_p_i
connect_bd_net [get_bd_ports dphy_data_p_i] [get_bd_pins csi2_2_lane_rx/dphy_data_p_i]
create_bd_port -dir I dphy_lp_clk_n_i
connect_bd_net [get_bd_ports dphy_lp_clk_n_i] [get_bd_pins csi2_2_lane_rx/dphy_lp_clk_n_i]
create_bd_port -dir I dphy_lp_clk_p_i
connect_bd_net [get_bd_ports dphy_lp_clk_p_i] [get_bd_pins csi2_2_lane_rx/dphy_lp_clk_p_i]
create_bd_port -dir I -from 1 -to 0 dphy_lp_data_n_i
connect_bd_net [get_bd_ports dphy_lp_data_n_i] [get_bd_pins csi2_2_lane_rx/dphy_lp_data_n_i]
create_bd_port -dir I -from 1 -to 0 dphy_lp_data_p_i
connect_bd_net [get_bd_ports dphy_lp_data_p_i] [get_bd_pins csi2_2_lane_rx/dphy_lp_data_p_i]
create_bd_port -dir O hdmi_clk_n_o
connect_bd_net [get_bd_ports hdmi_clk_n_o] [get_bd_pins hdmi_tx/hdmi_clk_n_o]
create_bd_port -dir O hdmi_clk_p_o
connect_bd_net [get_bd_ports hdmi_clk_p_o] [get_bd_pins hdmi_tx/hdmi_clk_p_o]
create_bd_port -dir O hdmi_tx0_n_o
connect_bd_net [get_bd_ports hdmi_tx0_n_o] [get_bd_pins hdmi_tx/hdmi_tx0_n_o]
create_bd_port -dir O hdmi_tx0_p_o
connect_bd_net [get_bd_ports hdmi_tx0_p_o] [get_bd_pins hdmi_tx/hdmi_tx0_p_o]
create_bd_port -dir O hdmi_tx1_n_o
connect_bd_net [get_bd_ports hdmi_tx1_n_o] [get_bd_pins hdmi_tx/hdmi_tx1_n_o]
create_bd_port -dir O hdmi_tx1_p_o
connect_bd_net [get_bd_ports hdmi_tx1_p_o] [get_bd_pins hdmi_tx/hdmi_tx1_p_o]
create_bd_port -dir O hdmi_tx2_n_o
connect_bd_net [get_bd_ports hdmi_tx2_n_o] [get_bd_pins hdmi_tx/hdmi_tx2_n_o]
create_bd_port -dir O hdmi_tx2_p_o
connect_bd_net [get_bd_ports hdmi_tx2_p_o] [get_bd_pins hdmi_tx/hdmi_tx2_p_o]
create_bd_port -dir IO sccb_sda_io
connect_bd_net [get_bd_ports sccb_sda_io] [get_bd_pins csi2_2_lane_rx/sccb_sda_io]
create_bd_port -dir IO sccb_scl_io
connect_bd_net [get_bd_ports sccb_scl_io] [get_bd_pins csi2_2_lane_rx/sccb_scl_io]

make_bd_intf_pins_external  [get_bd_intf_pins zynq_ps/DDR]
set_property name DDR [get_bd_intf_ports DDR_0]
make_bd_intf_pins_external  [get_bd_intf_pins zynq_ps/FIXED_IO]
set_property name FIXED_IO [get_bd_intf_ports FIXED_IO_0]
connect_bd_intf_net [get_bd_intf_ports DDR] [get_bd_intf_pins zynq_ps/DDR]
connect_bd_intf_net [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins zynq_ps/FIXED_IO]

# Managing slaves offsets
assign_bd_address [get_bd_addr_segs {csi2_2_lane_rx/csi2_csr/csi2_csr }]
assign_bd_address [get_bd_addr_segs {csi2_2_lane_rx/sccb_ctrl/sccb_ctrl }]
set_property offset 0x00010000 [get_bd_addr_segs {jtag_axi/Data/SEG_csi2_2_lane_rx_csi2_csr}]
set_property offset 0x00000000 [get_bd_addr_segs {jtag_axi/Data/SEG_csi2_2_lane_rx_sccb_ctrl}]
assign_bd_address [get_bd_addr_segs {zynq_ps/S_AXI_HP1/HP1_DDR_LOWOCM }]
assign_bd_address [get_bd_addr_segs {zynq_ps/S_AXI_HP0/HP0_DDR_LOWOCM }]

# Saving block design
regenerate_bd_layout
save_bd_design

# Create HDL Wraper
make_wrapper -files [get_files ./pandacam.srcs/sources_1/bd/pandacam/pandacam.bd] -top
add_files -norecurse ./pandacam.srcs/sources_1/bd/pandacam/hdl/pandacam_wrapper.v
update_compile_order -fileset sources_1

# Generate Output Products
generate_target all [get_files  ./pandacam.srcs/sources_1/bd/pandacam/pandacam.bd]
catch { config_ip_cache -export [get_ips -all pandacam_zynq_ps_0] }
catch { config_ip_cache -export [get_ips -all pandacam_px_clk_mmcm_0] }
catch { config_ip_cache -export [get_ips -all pandacam_xbar_0] }
catch { config_ip_cache -export [get_ips -all pandacam_ref_clk_rst_0] }
catch { config_ip_cache -export [get_ips -all pandacam_wr_clk_rst_0] }
catch { config_ip_cache -export [get_ips -all pandacam_rd_clk_rst_0] }
catch { config_ip_cache -export [get_ips -all pandacam_jtag_axi_0] }
catch { config_ip_cache -export [get_ips -all pandacam_hdmi_tx_0] }
catch { config_ip_cache -export [get_ips -all pandacam_csi2_2_lane_rx_0] }
catch { config_ip_cache -export [get_ips -all pandacam_frame_buffer_0] }
catch { config_ip_cache -export [get_ips -all pandacam_rgb_converter_0] }
catch { config_ip_cache -export [get_ips -all pandacam_auto_pc_0] }
catch { config_ip_cache -export [get_ips -all pandacam_auto_pc_1] }
catch { config_ip_cache -export [get_ips -all pandacam_auto_pc_2] }
export_ip_user_files -of_objects [get_files ./pandacam.srcs/sources_1/bd/pandacam/pandacam.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ./pandacam.srcs/sources_1/bd/pandacam/pandacam.bd]
launch_runs -jobs 4 {               \
  pandacam_zynq_ps_0_synth_1        \
  pandacam_px_clk_mmcm_0_synth_1    \
  pandacam_xbar_0_synth_1           \
  pandacam_ref_clk_rst_0_synth_1    \
  pandacam_wr_clk_rst_0_synth_1     \
  pandacam_rd_clk_rst_0_synth_1     \
  pandacam_jtag_axi_0_synth_1       \
  pandacam_hdmi_tx_0_synth_1        \
  pandacam_csi2_2_lane_rx_0_synth_1 \
  pandacam_frame_buffer_0_synth_1   \
  pandacam_rgb_converter_0_synth_1  \
  pandacam_auto_pc_0_synth_1        \
  pandacam_auto_pc_1_synth_1        \
  pandacam_auto_pc_2_synth_1}

wait_on_run pandacam_zynq_ps_0_synth_1
wait_on_run pandacam_px_clk_mmcm_0_synth_1
wait_on_run pandacam_xbar_0_synth_1
wait_on_run pandacam_ref_clk_rst_0_synth_1
wait_on_run pandacam_wr_clk_rst_0_synth_1
wait_on_run pandacam_rd_clk_rst_0_synth_1
wait_on_run pandacam_jtag_axi_0_synth_1
wait_on_run pandacam_hdmi_tx_0_synth_1
wait_on_run pandacam_csi2_2_lane_rx_0_synth_1
wait_on_run pandacam_frame_buffer_0_synth_1
wait_on_run pandacam_rgb_converter_0_synth_1
wait_on_run pandacam_auto_pc_0_synth_1
wait_on_run pandacam_auto_pc_1_synth_1
wait_on_run pandacam_auto_pc_2_synth_1

# RTL Elaboration
create_ip_run [get_files -of_objects [get_fileset sources_1] ./pandacam.srcs/sources_1/bd/pandacam/pandacam.bd]
synth_design -rtl -name rtl_1

# Pin placement
place_ports {dphy_data_p_i[0]} M19
place_ports {dphy_data_p_i[1]} L16
place_ports dphy_clk_p_i       J18
set_property IOSTANDARD LVDS_25 [get_ports [list \
  {dphy_data_p_i[1]}                           \
  {dphy_data_p_i[0]}                           \
  dphy_clk_p_i]]
place_ports sccb_sda_io       F19
place_ports sccb_scl_io       F20
place_ports cam_pwup_o        G20
set_property IOSTANDARD LVCMOS33 [get_ports [list \
  sccb_sda_io                                 \
  sccb_scl_io                                 \
  cam_pwup_o]]
place_ports dphy_lp_clk_p_i       H20
place_ports dphy_lp_clk_n_i       J19
place_ports {dphy_lp_data_p_i[0]} L19
place_ports {dphy_lp_data_p_i[1]} J20
place_ports {dphy_lp_data_n_i[0]} M18
place_ports {dphy_lp_data_n_i[1]} L20
set_property IOSTANDARD HSUL_12 [get_ports [list \
  dphy_lp_clk_p_i                              \
  dphy_lp_clk_n_i                              \
  {dphy_lp_data_p_i[0]}                        \
  {dphy_lp_data_p_i[1]}                        \
  {dphy_lp_data_n_i[0]}                        \
  {dphy_lp_data_n_i[1]}]]
set_property INTERNAL_VREF 0.6 [get_iobanks 35]
place_ports hdmi_clk_p_o H16
place_ports hdmi_tx0_p_o D19
place_ports hdmi_tx1_p_o C20
place_ports hdmi_tx2_p_o B19

# Creating directory for constraints
file mkdir ./pandacam.srcs/constrs_1/new

# Creating constraints file
close [ open ./pandacam.srcs/constrs_1/new/pandacam.xdc w ]

# Setting this file as target constraint
set_property target_constrs_file ./pandacam.srcs/constrs_1/new/pandacam.xdc [current_fileset -constrset]

# Timing constraints
create_clock -period 2.976 -name dphy_clk -waveform {0.000 1.488} [get_ports dphy_clk_p_i]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/byte_align[*].settle_ignore/FSM_onehot_state_reg[4]] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/hs_data_valid_d1_reg[*]] 5.000

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/hs_data_valid_d1_reg[*]]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/hs_data_valid_d2_reg[*]]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/clk_presence_cnt_reg[*]] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_loss_rst*] 5.000

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_loss_rst_d1_reg]

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_loss_rst_d2_reg]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_wr_clk_reg[*]] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_rd_clk_reg[*]] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_rd_clk_reg[*]]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/wr_ptr_gray_rd_clk_mtstb_reg[*]]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_rd_clk_reg[*]] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_wr_clk_reg[*]] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_wr_clk_reg[*]]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rd_ptr_gray_wr_clk_mtstb_reg[*]]

set_max_delay -datapath_only -from [get_cells pandacam_i/wr_clk_rst/U0/PR_OUT_DFF[0].FDRE_PER] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d1_reg] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d1_reg] 

set_max_delay -datapath_only -from [get_cells pandacam_i/wr_clk_rst/U0/PR_OUT_DFF[0].FDRE_PER] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d2_reg] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_wr_clk_d2_reg] 
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_rd_clk_d1_reg] 
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/dphy_int_cdc/rst_rd_clk_d2_reg]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_csr/cr_reg[1][0]] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/axi4_conv/enable_d1_reg] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/axi4_conv/enable_d1_reg]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/axi4_conv/enable_d2_reg]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_reg] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s1_reg] 5.000

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s1_reg]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s2_reg]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/phy/clk_detect/toggle_bit_s3_reg]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/crc_calc/crc_failed_o_reg] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/crc_err_d1_reg] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/crc_err_d1_reg]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/crc_err_d2_reg]

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/header_corrector/error_corrected_o_reg] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/corr_header_err_d1_reg] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/corr_header_err_d1_reg] 
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/corr_header_err_d2_reg] 

set_max_delay -datapath_only -from [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_rx/header_corrector/error_o_reg] -to \
                                   [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/header_err_d1_reg] 11.904

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/header_err_d1_reg] 
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/csi2_stat_acc/header_err_d2_reg] 

set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/sccb_master/i2c_master_phy/mstb_scl_reg[*]]
set_property ASYNC_REG TRUE [get_cells pandacam_i/csi2_2_lane_rx/inst/sccb_master/i2c_master_phy/mstb_sda_reg[*]]

# Saving previous constraints to file
save_constraints -force

# Run Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Generate bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Export Hardware
file mkdir ./pandacam.sdk
file copy -force ./pandacam.runs/impl_1/pandacam_wrapper.sysdef ./pandacam.sdk/pandacam_wrapper.hdf

exit
