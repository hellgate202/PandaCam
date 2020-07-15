#!/usr/bin/python3

import cv2
import sys
import numpy as np

srgb_1e = np.array( [249, 242, 238] )
srgb_2e = np.array( [202, 198, 195] )
srgb_3e = np.array( [161, 157, 154] )
srgb_4e = np.array( [122, 118, 116] )
srgb_5e = np.array( [80, 80, 78] )
srgb_6e = np.array( [43, 41, 43] )
srgb_1f = np.array( [0, 127, 159] )
srgb_2f = np.array( [192, 75, 145] )
srgb_3f = np.array( [245, 205, 0] )
srgb_4f = np.array( [186, 26, 51] )
srgb_5f = np.array( [57, 146, 64] )
srgb_6f = np.array( [25, 55, 135] )
srgb_1g = np.array( [222, 118, 32] )
srgb_2g = np.array( [58, 88, 159] )
srgb_3g = np.array( [195, 79, 95] )
srgb_4g = np.array( [83, 58, 106] )
srgb_5g = np.array( [157, 188, 54] )
srgb_6g = np.array( [238, 158, 25] )
srgb_1h = np.array( [98, 187, 166] )
srgb_2h = np.array( [126, 125, 174] )
srgb_3h = np.array( [82, 106, 60] )
srgb_4h = np.array( [87, 120, 155] )
srgb_5h = np.array( [197, 145, 125] )
srgb_6h = np.array( [112, 76, 60] )

img = cv2.imread( sys.argv[1] );
roi_list = cv2.selectROIs( "img", img, False, False );

def get_mean_color( coords ):
  crop = img[coords[1] : coords[1] + coords[3],
             coords[0] : coords[0] + coords[2]]
  crop_px = crop.shape[0] * crop.shape[1]
  crop_r = crop[:, :, 2]
  crop_g = crop[:, :, 1]
  crop_b = crop[:, :, 0]
  r_acc = 0
  g_acc = 0
  b_acc = 0
  for y in range( crop.shape[0] ):
    for x in range( crop.shape[1] ):
      r_acc += crop_r[y, x]
  r_mean = r_acc / crop_px
  for y in range( crop.shape[0] ):
    for x in range( crop.shape[1] ):
      g_acc += crop_g[y, x]
  g_mean = g_acc / crop_px
  for y in range( crop.shape[0] ):
    for x in range( crop.shape[1] ):
      b_acc += crop_b[y, x]
  b_mean = b_acc / crop_px
  return np.array( [r_mean, g_mean, b_mean] )

def srgb2rgb( srgb ):
  norm_rgb = np.zeros( 3 )
  norm_srgb = srgb / 256.0
  for c in range( 3 ):
    if( norm_srgb[c] < 0.0404 ):
      norm_rgb[c] = norm_srgb[c] / 12.92
    else:
      norm_rgb[c] = ( ( norm_srgb[c] + 0.055 ) / 1.055 ) ** 2.4
  return ( norm_rgb * 256 ).astype( int )

def rgb2srgb( rgb ):
  norm_srgb = np.zeros( 3 )
  norm_rgb = rgb / 256.0
  for c in range( 3 ):
    if( norm_rgb[c] < 0.0031 ):
      norm_srgb[c] = norm_rgb[c] * 12.92
    else:
      norm_srgb[c] = 1.055 * norm_rgb[c] ** ( 1 / 2.4 ) - 0.055
  return ( norm_srgb * 256 ).astype( int )

rgb_1e = srgb2rgb( srgb_1e )
rgb_2e = srgb2rgb( srgb_2e )
rgb_3e = srgb2rgb( srgb_3e )
rgb_4e = srgb2rgb( srgb_4e )
rgb_5e = srgb2rgb( srgb_5e )
rgb_6e = srgb2rgb( srgb_6e )
rgb_1f = srgb2rgb( srgb_1f )
rgb_2f = srgb2rgb( srgb_2f )
rgb_3f = srgb2rgb( srgb_3f )
rgb_4f = srgb2rgb( srgb_4f )
rgb_5f = srgb2rgb( srgb_5f )
rgb_6f = srgb2rgb( srgb_6f )
rgb_1g = srgb2rgb( srgb_1g )
rgb_2g = srgb2rgb( srgb_2g )
rgb_3g = srgb2rgb( srgb_3g )
rgb_4g = srgb2rgb( srgb_4g )
rgb_5g = srgb2rgb( srgb_5g )
rgb_6g = srgb2rgb( srgb_6g )
rgb_1h = srgb2rgb( srgb_1h )
rgb_2h = srgb2rgb( srgb_2h )
rgb_3h = srgb2rgb( srgb_3h )
rgb_4h = srgb2rgb( srgb_4h )
rgb_5h = srgb2rgb( srgb_5h )
rgb_6h = srgb2rgb( srgb_6h )

rgb_mat = np.array ([ rgb_1e, rgb_2e, rgb_3e, rgb_4e, rgb_5e, rgb_6e,
                      rgb_1f, rgb_2f, rgb_3f, rgb_4f, rgb_5f, rgb_6f,
                      rgb_1g, rgb_2g, rgb_3g, rgb_4g, rgb_5g, rgb_6g,
                      rgb_1h, rgb_2h, rgb_3h, rgb_4h, rgb_5h, rgb_6h]) * 4
rgb_mat.shape = (24, 3)

img_1e = srgb2rgb( get_mean_color( roi_list[0] ) )
img_2e = srgb2rgb( get_mean_color( roi_list[1] ) )
img_3e = srgb2rgb( get_mean_color( roi_list[2] ) )
img_4e = srgb2rgb( get_mean_color( roi_list[3] ) )
img_5e = srgb2rgb( get_mean_color( roi_list[4] ) )
img_6e = srgb2rgb( get_mean_color( roi_list[5] ) )
img_1f = srgb2rgb( get_mean_color( roi_list[6] ) )
img_2f = srgb2rgb( get_mean_color( roi_list[7] ) )
img_3f = srgb2rgb( get_mean_color( roi_list[8] ) )
img_4f = srgb2rgb( get_mean_color( roi_list[9] ) )
img_5f = srgb2rgb( get_mean_color( roi_list[10] ) )
img_6f = srgb2rgb( get_mean_color( roi_list[11] ) )
img_1g = srgb2rgb( get_mean_color( roi_list[12] ) )
img_2g = srgb2rgb( get_mean_color( roi_list[13] ) )
img_3g = srgb2rgb( get_mean_color( roi_list[14] ) )
img_4g = srgb2rgb( get_mean_color( roi_list[15] ) )
img_5g = srgb2rgb( get_mean_color( roi_list[16] ) )
img_6g = srgb2rgb( get_mean_color( roi_list[17] ) )
img_1h = srgb2rgb( get_mean_color( roi_list[18] ) )
img_2h = srgb2rgb( get_mean_color( roi_list[19] ) )
img_3h = srgb2rgb( get_mean_color( roi_list[20] ) )
img_4h = srgb2rgb( get_mean_color( roi_list[21] ) )
img_5h = srgb2rgb( get_mean_color( roi_list[22] ) )
img_6h = srgb2rgb( get_mean_color( roi_list[23] ) )

img_mat = np.array ([ img_1e, img_2e, img_3e, img_4e, img_5e, img_6e,
                      img_1f, img_2f, img_3f, img_4f, img_5f, img_6f,
                      img_1g, img_2g, img_3g, img_4g, img_5g, img_6g,
                      img_1h, img_2h, img_3h, img_4h, img_5h, img_6h]) * 4
img_mat.shape = (24, 3)
img_mat = np.hstack( (img_mat, np.ones( (24, 1) )) )
cc_mat = np.matmul( np.matmul( np.linalg.inv( np.matmul( img_mat.transpose(), img_mat ) ), img_mat.transpose() ), rgb_mat ).transpose()
print( cc_mat )

for y in range( 3 ):
  n = cc_mat[y, 0:3]
  n = np.hstack( (n * 1024, cc_mat[y, 3] )  )
  n = n * ( 1024 / np.sum( n ) ) / 1024
  n[3] = n[3] * 1024
  cc_mat[y, :] = n

print( cc_mat )
