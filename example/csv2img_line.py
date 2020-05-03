#!/usr/bin/python3

import csv
import sys

f_csv = open( sys.argv[1] )
f_hex = open( sys.argv[2], "a+" )

csv_dict = csv.DictReader( f_csv, delimiter=',' )

i = 0

for line in csv_dict:
  f_hex.write( line["pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_g[7:0]"] + "\n" )
  f_hex.write( line["pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_b[7:0]"] + "\n" )
  f_hex.write( line["pandacam_i/frame_buffer/inst/frame_buffer_inst/capture_logic.video_o_r[7:0]"] + "\n" )
  i = i + 1
  if i == 1920:
    break
