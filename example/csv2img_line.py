#!/usr/bin/python3

import csv
import sys

f_csv = open( sys.argv[1] )
f_hex = open( sys.argv[2], "a+" )

csv_dict = csv.DictReader( f_csv, delimiter=',' )

i = 0

for line in csv_dict:
  f_hex.write( line["pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o\\\\.tdata_1[9:2]"] + "\n" )
  f_hex.write( line["pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o\\\\.tdata_2[19:12]"] + "\n" )
  f_hex.write( line["pandacam_i/frame_buffer/inst/frame_buffer_inst/video_o\\\\.tdata[29:22]"] + "\n" )
  i = i + 1
  if i == 1920:
    break
