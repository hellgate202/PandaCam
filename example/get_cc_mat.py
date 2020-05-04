#!/usr/bin/python3

import cv2
import sys
import numpy as np

srgb_1e = [249, 242, 238]
srgb_2e = [202, 198, 195]
srgb_3e = [161, 157, 154]
srgb_4e = [122, 118, 116]
srgb_5e = [80, 80, 78]
srgb_6e = [43, 41, 43]
srgb_1f = [0, 127, 159]
srgb_2f = [192, 75, 145]
srgb_3f = [245, 205, 0]
srgb_4f = [186, 26, 51]
srgb_5f = [57, 146, 64]
srgb_6f = [25, 55, 135]
srgb_1g = [222, 118, 32]
srgb_2g = [58, 88, 159]
srgb_3g = [195, 79, 95]
srgb_4g = [83, 58, 106]
srgb_5g = [157, 188, 54]
srgb_6g = [238, 158, 25]
srgb_1h = [98, 187, 166]
srgb_2h = [126, 125, 174]
srgb_3h = [82, 106, 60]
srgb_4h = [87, 120, 155]
srgb_5h = [197, 145, 125]
srgb_6h = [112, 76, 60]

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
  return [r_mean, g_mean, b_mean]

rgb_1e = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_1e]
rgb_2e = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_2e]
rgb_3e = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_3e]
rgb_4e = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_4e]
rgb_5e = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_5e]
rgb_6e = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_6e]
rgb_1f = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_1f]
rgb_2f = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_2f]
rgb_3f = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_3f]
rgb_4f = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_4f]
rgb_5f = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_5f]
rgb_6f = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_6f]
rgb_1g = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_1g]
rgb_2g = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_2g]
rgb_3g = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_3g]
rgb_4g = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_4g]
rgb_5g = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_5g]
rgb_6g = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_6g]
rgb_1h = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_1h]
rgb_2h = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_2h]
rgb_3h = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_3h]
rgb_4h = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_4h]
rgb_5h = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_5h]
rgb_6h = [int( ( x / 256.0 ) ** 2.2 * 256 ) for x in srgb_6h]

rgb_mat = np.array ([ rgb_1e, rgb_2e, rgb_3e, rgb_4e, rgb_5e, rgb_6e,
                      rgb_1f, rgb_2f, rgb_3f, rgb_4f, rgb_5f, rgb_6f,
                      rgb_1g, rgb_2g, rgb_3g, rgb_4g, rgb_5g, rgb_6g,
                      rgb_1h, rgb_2h, rgb_3h, rgb_4h, rgb_5h, rgb_6h]) * 4
rgb_mat.shape = (24, 3)

img_1e = get_mean_color( roi_list[0] )
img_2e = get_mean_color( roi_list[1] )
img_3e = get_mean_color( roi_list[2] )
img_4e = get_mean_color( roi_list[3] )
img_5e = get_mean_color( roi_list[4] )
img_6e = get_mean_color( roi_list[5] )
img_1f = get_mean_color( roi_list[6] )
img_2f = get_mean_color( roi_list[7] )
img_3f = get_mean_color( roi_list[8] )
img_4f = get_mean_color( roi_list[9] )
img_5f = get_mean_color( roi_list[10] )
img_6f = get_mean_color( roi_list[11] )
img_1g = get_mean_color( roi_list[12] )
img_2g = get_mean_color( roi_list[13] )
img_3g = get_mean_color( roi_list[14] )
img_4g = get_mean_color( roi_list[15] )
img_5g = get_mean_color( roi_list[16] )
img_6g = get_mean_color( roi_list[17] )
img_1h = get_mean_color( roi_list[18] )
img_2h = get_mean_color( roi_list[19] )
img_3h = get_mean_color( roi_list[20] )
img_4h = get_mean_color( roi_list[21] )
img_5h = get_mean_color( roi_list[22] )
img_6h = get_mean_color( roi_list[23] )

img_mat = np.array ([ img_1e, img_2e, img_3e, img_4e, img_5e, img_6e,
                      img_1f, img_2f, img_3f, img_4f, img_5f, img_6f,
                      img_1g, img_2g, img_3g, img_4g, img_5g, img_6g,
                      img_1h, img_2h, img_3h, img_4h, img_5h, img_6h]) * 4
img_mat.shape = (24, 3)
img_mat = np.hstack( (img_mat, np.ones( (24, 1) )) )
cc_mat = np.matmul( np.matmul( np.linalg.inv( np.matmul( img_mat.transpose(), img_mat ) ), img_mat.transpose() ), rgb_mat ).transpose()

for y in range( 3 ):
  n = cc_mat[y, 0:3]
  n = np.hstack( (n * 1024, cc_mat[y, 3])  )
  n = n / np.sum( n )
  n[3] = n[3] * 1024
  cc_mat[y, :] = n

print( cc_mat )
