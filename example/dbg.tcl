set sccb_csr_offset            0x00000000
set csi2_csr_offset            0x00010000
set demosaicing_csr_offset     0x00020000
set white_ballance_csr_offset  0x00030000
set color_corrector_csr_offset 0x00040000

proc conv_csr { d } {
  set h 0x[format %+08s [format %x [expr {$d * 4}]]]
  return $h
}

proc rd { addr } { 
  create_hw_axi_txn read_txn -force [get_hw_axis hw_axi_1] -type READ -address $addr -len 1
  run_hw_axi [get_hw_axi_txns read_txn]
  after 1
  return [get_property DATA [get_hw_axi_txns read_txn]]
}
proc wr { addr data } { 
  run_hw_axi [create_hw_axi_txn write_txn -force [get_hw_axis hw_axi_1] -type WRITE -address $addr -len 1 -data $data] 
  after 1
}

proc rd_sccb_reg { addr } {
  set rd_data [rd 0x[format %+08s [format %x $addr]]]
  return 0x[string range $rd_data 6 7]
}

proc wr_sccb_reg { addr data } {
  set axi_addr [format %+08s [format %x $addr]]
  set axi_data [format %+08s [format %x $data]]
  wr $axi_addr $axi_data
}

proc rd_csr { offset reg_num } {
  set axi_addr 0x[format %+08s [format %x [expr {$offset + [conv_csr $reg_num]}]]]
  set rd_data [rd $axi_addr]
  return 0x$rd_data
}

proc wr_csr { offset reg_num data } {
  set axi_addr 0x[format %+08s [format %x [expr {$offset + [conv_csr $reg_num]}]]]
  set axi_data [format %+08s [format %x $data]]
  wr $axi_addr $axi_data
}

proc dphy_en {} {
  wr_csr $::csi2_csr_offset 1 1
  puts "PHY has been enabled"
}

proc dphy_dis {} {
  wr_csr $::csi2_csr_offset 1 0 
  puts "PHY has been disabled"
}

proc clear_stat {} {
  wr_csr $::csi2_csr_offset 0 0
  wr_csr $::csi2_csr_offset 0 1
  puts "Statistics cleared"
}

proc set_sccb_addr { sccb_addr } {
  wr_csr $::csi2_csr_offset 2 $sccb_addr
  puts "SCCB device ID has been set to 0x[string range [format %x $sccb_addr] 7 8]"
}

proc rst_cam {} {
  wr_csr $::csi2_csr_offset 6 0
  wr_csr $::csi2_csr_offset 6 1
  puts "Camera has been reseted"
}

proc get_head_err {} {
  puts "There were [format %d [rd_csr $::csi2_csr_offset 7]] header errors"
}

proc get_corr_head_err {} {
  puts "There were [format %d [rd_csr $::csi2_csr_offset 8]] corrected header errors "
}

proc get_crc_err {} {
  puts "There were [format %d [rd_csr $::csi2_csr_offset 9]] CRC errors"
}

proc get_max_ln {} {
  puts "Maximum frame size was [format %d [rd_csr $::csi2_csr_offset 10]] lines"
}

proc get_min_ln {} {
  puts "Minimum frame size was [format %d [rd_csr $::csi2_csr_offset 11]] lines"
}

proc get_max_px {} {
  puts "Maximum line size was [format %d [rd_csr $::csi2_csr_offset 12]] pixels"
}

proc get_min_px {} {
  puts "Minimum line size was [format %d 0x[rd_csr $::csi2_csr_offset 13]] pixels"
}

proc demosaicing_en {} {
  wr_csr $::demosaicing_csr_offset 0 1
  puts "Demosaicing has been enabled"
}

proc demosaicing_dis {} {
  wr_csr $::demosaicing_csr_offset 0 0
  puts "Demosaicing has been disabled"
}

proc set_demosaicing { pattern } {
  if { $pattern == "rggb" } {
    wr_csr $::demosaicing_csr_offset 1 0
  } elseif { $pattern == "grbg" } {
    wr_csr $::demosaicing_csr_offset 1 1
  } elseif { $pattern == "gbrg" } {
    wr_csr $::demosaicing_csr_offset 1 2
  } elseif { $pattern == "bggr" } {
    wr_csr $::demosaicing_csr_offset 1 3
  } else {
    puts "Unsupported Bayer pattern"
  }
}

proc set_wb_coefficients {r g b} {
  set r_int [expr {int( $r )}]
  set r_fract [expr {int( ( $r - $r_int ) * 2 ** 10 )}]
  set r 0x[format %+08s [format %x [expr {$r_fract + $r_int * 2 ** 10}]]]
  set g_int [expr {int( $g )}]
  set g_fract [expr {int( ( $g - $g_int ) * 2 ** 10 )}]
  set g 0x[format %+08s [format %x [expr {$g_fract + $g_int * 2 ** 10}]]]
  set b_int [expr {int( $b )}]
  set b_fract [expr {int( ( $b - $b_int ) * 2 ** 10 )}]
  set b 0x[format %+08s [format %x [expr {$b_fract + $b_int * 2 ** 10}]]]
  wr_csr $::white_ballance_csr_offset 2 0
  wr_csr $::white_ballance_csr_offset 3 $r
  wr_csr $::white_ballance_csr_offset 4 0
  wr_csr $::white_ballance_csr_offset 4 1
  wr_csr $::white_ballance_csr_offset 2 1
  wr_csr $::white_ballance_csr_offset 3 $g
  wr_csr $::white_ballance_csr_offset 4 0
  wr_csr $::white_ballance_csr_offset 4 1
  wr_csr $::white_ballance_csr_offset 2 2
  wr_csr $::white_ballance_csr_offset 3 $b
  wr_csr $::white_ballance_csr_offset 4 0
  wr_csr $::white_ballance_csr_offset 4 1
}

proc set_wb_mode { mode } {
  if { $mode == "auto_gw" } {
    wr_csr $::white_ballance_csr_offset 0 0
  } elseif { $mode == "auto_retinex" } {
    wr_csr $::white_ballance_csr_offset 0 1
  } elseif { $mode == "manual" } {
    wr_csr $::white_ballance_csr_offset 0 2
  } elseif { $mode == "calibration" } {
    wr_csr $::white_ballance_csr_offset 0 3
  } elseif { $mode == "off" } {
    set_wb_coefficients 1.0 1.0 1.0
    wr_csr $::white_ballance_csr_offset 0 2
  } else {
    puts "Unsuported white balance mode"
  }
}

proc wb_calibrate {} {
  set wb_mode [rd_csr $::white_ballance_csr_offset 0]
  if { $wb_mode != 0x00000003 } {
    return "White balance corrector is not in calibration mode"
  }
  wr_csr $::white_ballance_csr_offset 1 0
  wr_csr $::white_ballance_csr_offset 1 1
}

proc cc_set_one_element { n value } {
  if { $value >= 0 } {
    set sign 0
  } else {
    set sign 1
  }
  set value [expr {abs( $value )}]
  set value_int [expr {int( $value )}]
  set value_fract [expr {int( ( $value - $value_int ) * 2 ** 10 )}]
  set value [expr {$value_fract + $value_int * 2 ** 10}]
  if { $sign } {
    set value 0x[format %+08s [format %x [expr {$value + 2 ** 20}]]]
  }
  switch $n {
    a11 {
      wr_csr $::color_corrector_csr_offset 1 0
    }
    a12 {
      wr_csr $::color_corrector_csr_offset 1 1
    }
    a13 {
      wr_csr $::color_corrector_csr_offset 1 2
    }
    a14 {
      wr_csr $::color_corrector_csr_offset 1 3
    }
    a21 {
      wr_csr $::color_corrector_csr_offset 1 4
    }
    a22 {
      wr_csr $::color_corrector_csr_offset 1 5
    }
    a23 {
      wr_csr $::color_corrector_csr_offset 1 6
    }
    a24 {
      wr_csr $::color_corrector_csr_offset 1 7
    }
    a31 {
      wr_csr $::color_corrector_csr_offset 1 8
    }
    a32 {
      wr_csr $::color_corrector_csr_offset 1 9
    }
    a33 {
      wr_csr $::color_corrector_csr_offset 1 10
    }
    a34 {
      wr_csr $::color_corrector_csr_offset 1 11
    }
    default {
      puts "Wrong element number"
    }
  }
  wr_csr $::color_corrector_csr_offset 2 $value
  wr_csr $::color_corrector_csr_offset 0 1
  wr_csr $::color_corrector_csr_offset 0 0
}

proc set_cc_matrix { a11 a12 a13 a14 a21 a22 a23 a24 a31 a32 a33 a34 } {
  cc_set_one_element a11 $a11
  cc_set_one_element a12 $a12
  cc_set_one_element a13 $a13
  cc_set_one_element a14 $a14
  cc_set_one_element a21 $a21
  cc_set_one_element a22 $a22
  cc_set_one_element a23 $a23
  cc_set_one_element a24 $a24
  cc_set_one_element a31 $a31
  cc_set_one_element a32 $a32
  cc_set_one_element a33 $a33
  cc_set_one_element a34 $a34
}

proc set_exposure { e } {
  wr_sccb_reg 0x3500 0x00
  wr_sccb_reg 0x3501 0x[format %+02s [format %x $e]]
}

proc set_gain { g } {
  wr_sccb_reg 0x350a [expr {$g / 256}]
  wr_sccb_reg 0x350b [expr {$g % 256}]
}

proc get_snapshot {} {
  dphy_dis
  set_property CONTROL.TRIGGER_POSITION 0 [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
  set_property CONTROL.CAPTURE_MODE BASIC [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
    set_property TRIGGER_COMPARE_VALUE eq11'hXXX [get_hw_probes pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.line_cnt -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  set_property TRIGGER_COMPARE_VALUE eq1'bX [get_hw_probes pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tfirst -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tready} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tvalid} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tuser} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  set_property CAPTURE_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tvalid} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  set_property CAPTURE_COMPARE_VALUE eq1'b1 [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tready} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
  wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
  upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
  write_hw_ila_data -force -csv_file {/home/liv/fpga/PandaCam/example/capture.csv} hw_ila_data_1
  exec ./csv2img_line.py ./capture.csv ./img.hex
  puts "1 / 1080 captured"
  
  set_property TRIGGER_COMPARE_VALUE eq1'bX [get_hw_probes {pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tuser} -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  set_property TRIGGER_COMPARE_VALUE eq1'b1 [get_hw_probes pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_tfirst -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
  
  for {set i 1} {$i < 1080} {incr i} {
    set line_num [format %+03s [format %x $i]]
    set_property TRIGGER_COMPARE_VALUE eq11'h$line_num [get_hw_probes pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.line_cnt -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]]
    run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
    wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
    upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xc7z020_1] -filter {CELL_NAME=~"u_ila_0"}]
    write_hw_ila_data -force -csv_file {/home/liv/fpga/PandaCam/example/capture.csv} hw_ila_data_1
    exec ./csv2img_line.py ./capture.csv ./img.hex
    puts "[expr {$i + 1}] / 1080 captured"
  }
  dphy_en
}
