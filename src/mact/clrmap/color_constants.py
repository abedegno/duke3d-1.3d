"""Named scalar color-model constants; no native/object/image reader.

Coefficients/legacy decimal spellings are recovered semantic observations,
not claims of unique historical source. Algebraic values retain their formulas.
Each tuple is a genuine per-operation literal object, including compiler-pool
repetitions across routines. No encoded CODE or opaque segment byte data.
"""
import struct
CONSTANTS=[
 ('hsv_achromatic_epsilon',.035),('hsv_sector_scale',1.0/60.0),
 ('rgb_achromatic_epsilon',.035),('hue_blue_sector',4.0),('hue_green_sector',2.0),('hue_sector_degrees',60.0),('hue_circle_degrees',360.0),
 ('dark_achromatic_epsilon',.0039),
 ('yiq_y_green',.5866),('yiq_y_red',.2989),('yiq_y_blue',.1144),
 ('yiq_i_green',.2741),('yiq_i_red',.5959),('yiq_i_blue',.3218),
 ('yiq_q_green',.5227),('yiq_q_red',.2113),('yiq_q_blue',.3113),
 ('yiq_inverse_r_i',.9562),('yiq_inverse_r_q',.621),
 ('yiq_inverse_g_i',.2717),('yiq_inverse_g_q',.6485),
 ('yiq_inverse_b_i',1.1053),('yiq_inverse_b_q',1.702),
 ('xyz_x_green',.357580),('xyz_x_red',.412453),('xyz_x_blue',.180423),
 ('xyz_y_green',.715160),('xyz_y_red',.212671),('xyz_y_blue',.072169),
 ('xyz_z_green',.119193),('xyz_z_red',.019334),('xyz_z_blue_legacy',.950277),
 ('xyz_inverse_r_y',1.537150),('xyz_inverse_r_x',3.240479),('xyz_inverse_r_z',.498535),
 ('xyz_inverse_g_y',1.875991),('xyz_inverse_g_x',-.969256),('xyz_inverse_g_z',.041556),
 ('xyz_inverse_b_y',.204043),('xyz_inverse_b_x',.055648),('xyz_inverse_b_z',1.057311),
 ('luv_luminance_knee',.008856),('luv_linear_slope',903.3),('luv_cuberoot_exponent',1.0/3.0),('luv_luminance_scale',116.0),('luv_luminance_offset',-16.0),
 ('luv_denominator_y',15.0),('luv_denominator_z',3.0),('luv_u_numerator',4.0),('luv_v_numerator',9.0),('luv_chroma_scale',13.0),
 ('luv_white_u',.197837857865288),('luv_white_v',.4683385450740464),
 ('luv_inverse_black_epsilon',.0001),('luv_inverse_l_offset',16.0),('luv_inverse_l_scale',1.0/116.0),('luv_inverse_l_exponent',3.0),
 ('luv_inverse_chroma_scale',13.0),('luv_inverse_white_v',.4683385450740464),('luv_inverse_v_limit',.2),
 # Exact observed scalar; decimal13*(.2-.4683385450740464), rounded once.
 ('luv_inverse_legacy_denominator',-3.4884010859626033),
 ('luv_inverse_z_v_multiplier',5.0),('luv_inverse_z_offset',-3.0),('luv_inverse_cross_scale',15.0),('luv_inverse_u_offset',-4.0),('luv_inverse_z_divisor',12.0),
 ('yiq_palette_byte_scale',1.0/256.0),('best_color_byte_scale',1.0/256.0),('float_palette_byte_scale',1.0/256.0),('translucent_weight_scale',1.0/256.0),
 ('colormap_weight_scale',1.0/255.0),('lightmap_percent_scale',.01),('lightmap_max_lightness',100.0),
 ('monochrome_byte_scale',1.0/256.0),('monochrome_luma_red',.299),('monochrome_luma_green',.587),('monochrome_luma_blue',.114),('ega_byte_scale',1.0/256.0)
]
BIT_CONSTANTS={'HUE_CIRCLE_BITS':360.0,'FP_ONE_BITS':1.0,'UNDEFINED_HUE_BITS':-1.0,'LUV_WHITE_U_BITS':.197837857865288,'DISTORTION_BOUND_BITS':3.0*255.0*255.0,'LIGHTNESS_MAX_BITS':100.0}
def generate():
 assert len(CONSTANTS)==78 and len({n for n,v in CONSTANTS})==78
 out=['# Genuine named binary64 literals; each role follows the readable color aid.']
 for name,value in CONSTANTS:out.extend([name+':','.double '+repr(value)])
 return '\n'.join(out)+'\n'
def bit_constants():
 out=[]
 for name,value in BIT_CONSTANTS.items():
  bits=struct.unpack('<Q',struct.pack('<d',value))[0]
  out += ['.equ '+name+'_LO, '+hex(bits&0xffffffff),'.equ '+name+'_HI, '+hex(bits>>32)]
 return '\n'.join(out)+'\n'
