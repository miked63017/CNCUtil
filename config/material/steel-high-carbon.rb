# stee_high_carbon.rb

diams    =[0.062,   0.125,  0.187, 2.250,  0.375, 0.500,  0.750,   1.0]
rpms     =[ 4930,    2150,   1433,  1075,    716,   537,    358,   268]
per_tooth=[0.0005, 0.0007, 0.0009, 0.001, 0.0015, 0.002, 0.0025, 0.003]
cut_depth=[0.04,    0.045,   0.05, 0.055,   0.06,  0.65,   0.07, 0.075]

   # these two arrays are used to calculate a recomended
   # maximum RPM at a given bit size for this material.
   # assuming high speed steel.  You can generally double
 

sfm_rough       =  70
sfm_finish      =  30
sfm_depth       =  0.08  # when taking a full width cut.


