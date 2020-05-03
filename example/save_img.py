#!/usr/bin/python3

import numpy as np
import cv2
import sys

img_path = sys.argv[1]
x = int( sys.argv[2] )
y = int( sys.argv[3] )
px_width = int( sys.argv[4] )
value_mult = 2 ** ( px_width - 8 )

d_img = np.zeros( ( y, x, 3 ), np.uint8 )

d = open( img_path )

print( "Reading output image..." )
for i in range( y ):
  for j in range( x ):
    l = d.readline().strip()
    d_img[i][j][1] = ( int( ( "0x" + l ), 16 ) / value_mult );
    l = d.readline().strip()
    d_img[i][j][0] = ( int( ( "0x" + l ), 16 ) / value_mult );
    l = d.readline().strip()
    d_img[i][j][2] = ( int( ( "0x" + l ), 16 ) / value_mult );

cv2.imwrite( "snapshot.png", d_img )
