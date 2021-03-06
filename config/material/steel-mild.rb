# mild_steel.rb
# material mild steel low carbon

self.rpms     =[  4930,   2465,   1643,  1232,    821,   616,    410,    308]
self.diams    =[ 0.062,  0.125,  0.187, 2.250,  0.375, 0.500,  0.750,    1.0]
self.per_tooth=[0.0010, 0.0015, 0.0020, 0.025, 0.0030, 0.032, 0.0035, 0.0040]
self.cut_depth=[  0.04,  0.045,   0.05, 0.055,   0.06,  0.65,   0.07,  0.075]

   # these two arrays are used to calculate a recomended
   # maximum RPM at a given bit size for this material.
   # assuming high speed steel.  You can generally double
 
self.brinell         =  0 
self.sfm_rough       =  80
self.sfm_finish      =  30
self.sfm_depth       =  0.08
