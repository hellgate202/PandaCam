#!/usr/bin/python3

import cv2
import sys
import numpy as np

srgb_1a = np.array( [210, 121, 117] )
srgb_2a = np.array( [216, 179, 90] )
srgb_3a = np.array( [127, 175, 120] )
srgb_4a = np.array( [66, 157, 19] )
srgb_5a = np.array( [116, 147, 194] )
srgb_6a = np.array( [190, 121, 154] )
srgb_1b = np.array( [218, 203, 201] )
srgb_2b = np.array( [203, 205, 196] )
srgb_3b = np.array( [206, 203, 208] )
srgb_4b = np.array( [66, 57, 58] )
srgb_5b = np.array( [54, 61, 56] )
srgb_6b = np.array( [63, 60, 69] )
srgb_1c = np.array( [237, 206, 186] )
srgb_2c = np.array( [211, 175, 133] )
srgb_3c = np.array( [193, 149, 91] )
srgb_4c = np.array( [139, 93, 61] )
srgb_5c = np.array( [74, 55, 46] )
srgb_6c = np.array( [57, 54, 56] )
srgb_1d = np.array( [241, 233, 229] )
srgb_2d = np.array( [229, 222, 220] )
srgb_3d = np.array( [182, 178, 176] )
srgb_4d = np.array( [139, 136, 135] )
srgb_5d = np.array( [100, 99, 97] )
srgb_6d = np.array( [63, 61, 62] )
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
  norm_srgb = srgb / 1024.0
  for c in range( 3 ):
    if( norm_srgb[c] < 0.0404 ):
      norm_rgb[c] = norm_srgb[c] / 12.92
    else:
      norm_rgb[c] = ( ( norm_srgb[c] + 0.055 ) / 1.055 ) ** 2.4
  return ( norm_rgb * 1024 ).astype( int )

def rgb2srgb( rgb ):
  norm_srgb = np.zeros( 3 )
  norm_rgb = rgb / 1024.0
  for c in range( 3 ):
    if( norm_rgb[c] < 0.0031 ):
      norm_srgb[c] = norm_rgb[c] * 12.92
    else:
      norm_srgb[c] = 1.055 * norm_rgb[c] ** ( 1 / 2.4 ) - 0.055
  return ( norm_srgb * 1024 ).astype( int )

rgb_1a = srgb2rgb( srgb_1a * 4 )
rgb_2a = srgb2rgb( srgb_2a * 4 )
rgb_3a = srgb2rgb( srgb_3a * 4 )
rgb_4a = srgb2rgb( srgb_4a * 4 )
rgb_5a = srgb2rgb( srgb_5a * 4 )
rgb_6a = srgb2rgb( srgb_6a * 4 )
rgb_1b = srgb2rgb( srgb_1b * 4 )
rgb_2b = srgb2rgb( srgb_2b * 4 )
rgb_3b = srgb2rgb( srgb_3b * 4 )
rgb_4b = srgb2rgb( srgb_4b * 4 )
rgb_5b = srgb2rgb( srgb_5b * 4 )
rgb_6b = srgb2rgb( srgb_6b * 4 )
rgb_1c = srgb2rgb( srgb_1c * 4 )
rgb_2c = srgb2rgb( srgb_2c * 4 )
rgb_3c = srgb2rgb( srgb_3c * 4 )
rgb_4c = srgb2rgb( srgb_4c * 4 )
rgb_5c = srgb2rgb( srgb_5c * 4 )
rgb_6c = srgb2rgb( srgb_6c * 4 )
rgb_1d = srgb2rgb( srgb_1d * 4 )
rgb_2d = srgb2rgb( srgb_2d * 4 )
rgb_3d = srgb2rgb( srgb_3d * 4 )
rgb_4d = srgb2rgb( srgb_4d * 4 )
rgb_5d = srgb2rgb( srgb_5d * 4 )
rgb_6d = srgb2rgb( srgb_6d * 4 )
rgb_1e = srgb2rgb( srgb_1e * 4 )
rgb_2e = srgb2rgb( srgb_2e * 4 )
rgb_3e = srgb2rgb( srgb_3e * 4 )
rgb_4e = srgb2rgb( srgb_4e * 4 )
rgb_5e = srgb2rgb( srgb_5e * 4 )
rgb_6e = srgb2rgb( srgb_6e * 4 )
rgb_1f = srgb2rgb( srgb_1f * 4 )
rgb_2f = srgb2rgb( srgb_2f * 4 )
rgb_3f = srgb2rgb( srgb_3f * 4 )
rgb_4f = srgb2rgb( srgb_4f * 4 )
rgb_5f = srgb2rgb( srgb_5f * 4 )
rgb_6f = srgb2rgb( srgb_6f * 4 )
rgb_1g = srgb2rgb( srgb_1g * 4 )
rgb_2g = srgb2rgb( srgb_2g * 4 )
rgb_3g = srgb2rgb( srgb_3g * 4 )
rgb_4g = srgb2rgb( srgb_4g * 4 )
rgb_5g = srgb2rgb( srgb_5g * 4 )
rgb_6g = srgb2rgb( srgb_6g * 4 )
rgb_1h = srgb2rgb( srgb_1h * 4 )
rgb_2h = srgb2rgb( srgb_2h * 4 )
rgb_3h = srgb2rgb( srgb_3h * 4 )
rgb_4h = srgb2rgb( srgb_4h * 4 )
rgb_5h = srgb2rgb( srgb_5h * 4 )
rgb_6h = srgb2rgb( srgb_6h * 4 )

rgb_mat = np.array ([ rgb_1a, rgb_2a, rgb_3a, rgb_4a, rgb_5a, rgb_6a,
                      rgb_1b, rgb_2b, rgb_3b, rgb_4b, rgb_5b, rgb_6b,
                      rgb_1c, rgb_2c, rgb_3c, rgb_4c, rgb_5c, rgb_6c,
                      rgb_1d, rgb_2d, rgb_3d, rgb_4d, rgb_5d, rgb_6d,
                      rgb_1e, rgb_2e, rgb_3e, rgb_4e, rgb_5e, rgb_6e,
                      rgb_1f, rgb_2f, rgb_3f, rgb_4f, rgb_5f, rgb_6f,
                      rgb_1g, rgb_2g, rgb_3g, rgb_4g, rgb_5g, rgb_6g,
                      rgb_1h, rgb_2h, rgb_3h, rgb_4h, rgb_5h, rgb_6h])
rgb_mat.shape = (48, 3)

img_1a = srgb2rgb( get_mean_color( roi_list[0] ) * 4 )
img_2a = srgb2rgb( get_mean_color( roi_list[1] ) * 4 )
img_3a = srgb2rgb( get_mean_color( roi_list[2] ) * 4 )
img_4a = srgb2rgb( get_mean_color( roi_list[3] ) * 4 )
img_5a = srgb2rgb( get_mean_color( roi_list[4] ) * 4 )
img_6a = srgb2rgb( get_mean_color( roi_list[5] ) * 4 )
img_1b = srgb2rgb( get_mean_color( roi_list[6] ) * 4 )
img_2b = srgb2rgb( get_mean_color( roi_list[7] ) * 4 )
img_3b = srgb2rgb( get_mean_color( roi_list[8] ) * 4 )
img_4b = srgb2rgb( get_mean_color( roi_list[9] ) * 4 )
img_5b = srgb2rgb( get_mean_color( roi_list[10] ) * 4 )
img_6b = srgb2rgb( get_mean_color( roi_list[11] ) * 4 )
img_1c = srgb2rgb( get_mean_color( roi_list[12] ) * 4 )
img_2c = srgb2rgb( get_mean_color( roi_list[13] ) * 4 )
img_3c = srgb2rgb( get_mean_color( roi_list[14] ) * 4 )
img_4c = srgb2rgb( get_mean_color( roi_list[15] ) * 4 )
img_5c = srgb2rgb( get_mean_color( roi_list[16] ) * 4 )
img_6c = srgb2rgb( get_mean_color( roi_list[17] ) * 4 )
img_1d = srgb2rgb( get_mean_color( roi_list[18] ) * 4 )
img_2d = srgb2rgb( get_mean_color( roi_list[19] ) * 4 )
img_3d = srgb2rgb( get_mean_color( roi_list[20] ) * 4 )
img_4d = srgb2rgb( get_mean_color( roi_list[21] ) * 4 )
img_5d = srgb2rgb( get_mean_color( roi_list[22] ) * 4 )
img_6d = srgb2rgb( get_mean_color( roi_list[23] ) * 4 )
img_1e = srgb2rgb( get_mean_color( roi_list[24] ) * 4 )
img_2e = srgb2rgb( get_mean_color( roi_list[25] ) * 4 )
img_3e = srgb2rgb( get_mean_color( roi_list[26] ) * 4 )
img_4e = srgb2rgb( get_mean_color( roi_list[27] ) * 4 )
img_5e = srgb2rgb( get_mean_color( roi_list[28] ) * 4 )
img_6e = srgb2rgb( get_mean_color( roi_list[29] ) * 4 )
img_1f = srgb2rgb( get_mean_color( roi_list[30] ) * 4 )
img_2f = srgb2rgb( get_mean_color( roi_list[31] ) * 4 )
img_3f = srgb2rgb( get_mean_color( roi_list[32] ) * 4 )
img_4f = srgb2rgb( get_mean_color( roi_list[33] ) * 4 )
img_5f = srgb2rgb( get_mean_color( roi_list[34] ) * 4 )
img_6f = srgb2rgb( get_mean_color( roi_list[35] ) * 4 )
img_1g = srgb2rgb( get_mean_color( roi_list[36] ) * 4 )
img_2g = srgb2rgb( get_mean_color( roi_list[37] ) * 4 )
img_3g = srgb2rgb( get_mean_color( roi_list[38] ) * 4 )
img_4g = srgb2rgb( get_mean_color( roi_list[39] ) * 4 )
img_5g = srgb2rgb( get_mean_color( roi_list[40] ) * 4 )
img_6g = srgb2rgb( get_mean_color( roi_list[41] ) * 4 )
img_1h = srgb2rgb( get_mean_color( roi_list[42] ) * 4 )
img_2h = srgb2rgb( get_mean_color( roi_list[43] ) * 4 )
img_3h = srgb2rgb( get_mean_color( roi_list[44] ) * 4 )
img_4h = srgb2rgb( get_mean_color( roi_list[45] ) * 4 )
img_5h = srgb2rgb( get_mean_color( roi_list[46] ) * 4 )
img_6h = srgb2rgb( get_mean_color( roi_list[47] ) * 4 )

img_mat = np.array ([ img_1a, img_2a, img_3a, img_4a, img_5a, img_6a,
                      img_1b, img_2b, img_3b, img_4b, img_5b, img_6b,
                      img_1c, img_2c, img_3c, img_4c, img_5c, img_6c,
                      img_1d, img_2d, img_3d, img_4d, img_5d, img_6d,
                      img_1e, img_2e, img_3e, img_4e, img_5e, img_6e,
                      img_1f, img_2f, img_3f, img_4f, img_5f, img_6f,
                      img_1g, img_2g, img_3g, img_4g, img_5g, img_6g,
                      img_1h, img_2h, img_3h, img_4h, img_5h, img_6h])
img_mat.shape = (48, 3)
img_mat = np.hstack( (img_mat, np.ones( (48, 1) )) )
cc_mat = np.matmul( np.matmul( np.linalg.inv( np.matmul( img_mat.transpose(), img_mat ) ), img_mat.transpose() ), rgb_mat ).transpose()

print( cc_mat )
for y in range( 3 ):
  for x in range( 4 ):
    print( "%.3f" % cc_mat[y][x] )
