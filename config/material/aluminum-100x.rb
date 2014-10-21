# aluminum-100x.rb
# Aluminum extrusion and plate

   # these two arrays are used to calculate a recomended
   # maximum RPM at a given bit size for this material.
   # assuming high speed steel.  You can generally double
   # the RPM speed for carbid and take a slightly higher
   # per tooth rating.

   
self.diams    =[0.062, 0.125, 0.187,  2.250, 0.375, 0.500, 0.750,  1.0]
#self.rpms     =[24600, 12300,  8215,   6150,  4107,  3075,  2053, 1532]

self.rpms     =[6500, 6500,  6500,   6150,  4107,  3075,  2053, 1000]


self.per_tooth=[0.0003, 0.0003, 0.0004,  0.0005, 0.0006, 0.0007, 0.0008,  0.001]

#self.per_tooth=[0.0015, 0.0015, 0.002,  0.0025, 0.003, 0.0034, 0.004,  0.005]

#self.cut_depth=[0.10,   0.11,  0.12,   0.15,  0.16,  0.17,  0.18,  0.19]

self.cut_depth=[0.015,   0.011,  0.012,   0.015,  0.016,  0.017,  0.018,  0.019]
  

   
self.brinell         =  0.0
self.sfm_rough       =  600
self.sfm_finish      =  900
self.sfm_depth       =  0.10



