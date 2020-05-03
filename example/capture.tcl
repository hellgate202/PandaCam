open_project pandacam.xpr
open_hw
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210351A6C9FAA]
set_property PARAM.FREQUENCY 30000000 [get_hw_targets */xilinx_tcf/Digilent/210351A6C9FAA]
open_hw_target
set_property PROGRAM.FILE {./pandacam.runs/impl_1/pandacam_wrapper.bit} [get_hw_devices xc7z020_1]
set_property PROBES.FILE {./pandacam.runs/impl_1/pandacam_wrapper.ltx} [get_hw_devices xc7z020_1]
set_property FULL_PROBES.FILE {./pandacam.runs/impl_1/pandacam_wrapper.ltx} [get_hw_devices xc7z020_1]
current_hw_device [get_hw_devices xc7z020_1]
refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]

set_property CONTROL.CAPTURE_MODE BASIC [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o_tfirst -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq11'h001 [get_hw_probes pandacam_i/frame_buffer/inst/frame_buffer_inst/line_cnt -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o\\.tready} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o\\.tvalid} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
set_property CAPTURE_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o\\.tvalid} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
set_property CAPTURE_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o\\.tready} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
write_hw_ila_data -force -csv_file {/home/liv/fpga/PandaCam/example/capture.csv} hw_ila_data_1
exit
