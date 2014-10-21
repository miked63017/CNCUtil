# brass.rb
# Brass 
#
#
rpms =[24600, 12300,  8215,  6150,   4107,  3075, 2053, 1532]
diams=[0.062, 0.125, 0.187,  2.250, 0.375, 0.500, 0.750, 1.0]
   # these two arrays are used to calculate a recomended
   # maximum RPM at a given bit size for this material.
   # assuming high speed steel.  You can generally double
   # this speed for Carbide.
 

feed_per_tooth  = 0.003       # up to 1/4" end mill
feed_per_tooth_large = 0.01  # 1/4" to 1" end mill
sfm_rough       =  600
sfm_finish      =  200
max_cut_depth   =  0.08  # when taking a full width cut.



