# test_polygon.rb
##  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
##  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'CNCMill'
require 'CNCShapePolygon'


######################################
def test_hexagon
######################################
  aMill = CNCMill.new
  aMill.job_start()
  aMill.home()
  #  variables used here to make
  #  easy for reader.

  return mill_hex_pocket(
      mill   = aMill,
      cent_x = 1.0,
      cent_y = 1.0,
      diam   = 0.25, 
      depth  = -0.3)

  mill.job_finish()
end #meth




######################################
def test_pentagon_outline
######################################
  aMill = CNCMill.new
  aMill.job_start()
  aMill.home()
  #  variables used here to make
  #  easy for reader.

  aRes = mill_polygon(mill = aMill,
     cent_x = 1.5,   cent_y = 1.5,
     diam = 0.5, num_side = 5, 
     depth=-0.2, 
     cutter_comp=true)

  mill.job_finish()
  return aRes
end #meth




######################################
def test_octagon_outline
######################################
  aMill = CNCMill.new
  aMill.job_start()
  aMill.home()
  #  variables used here to make
  #  easy for reader.
  aRes = mill_polygon(mill = aMill,
     cent_x = 0.8,   cent_y = 1.9,
     diam = 0.75, num_side = 8, 
     depth=-0.2, 
     cutter_comp=true)
  mill.job_finish()
  return aRes
end #meth



######################################
def test_octagon_pocket
######################################
  aMill = CNCMill.new
  aMill.job_start()
  aMill.home()
  #  variables used here to make
  #  easy for reader.
  aPoly =  CNCShapePolygon.new(aMill,  
    cent_x = 2.5,  cent_y = 1.5,        
    start_z = 0.0, diam=1.5,  num_sides=6,
    depth=-1.2,  degree_inc=nil)
  aPoly.do_mill()
  aMill.job_finish()
end #meth




######################################
def test_polygon_array
######################################
  aMill = CNCMill.new
  aMill.job_start()
  aMill.home()
  #  variables used here to make
  #  easy for reader.
  aPoly =  CNCShapePolygon.new(aMill,  
    cent_x = 2,  cent_y = 2,        
    start_z = 0.0, diam=0.38,  num_sides=6,
    depth=-1.8,  degree_inc=nil)

  aPoly.circ_array(
    circ_x = 2,
    circ_y = 2, 
    radius = 1.5, 
    beg_degree = 0, 
    end_degree = 360,
    num_elem   = 8)

  aMill.job_finish()
end #meth




########################################
####### MAIN TEST AREA
########################################
 aMill = CNCMill.new
  aMill.job_start()
  aRes = mill_polygon(mill = aMill,
     cent_x = 1.5,   cent_y = 1.5,
     diam = 1.5, num_side = 8, 
     depth=-0.2, 
     cutter_comp=true)
    aMill.job_finish()  
     
print "(hexagon)\n"
#test_hexagon
print "(pentagon)\n"
#test_pentagon_outline
print "(octagon)\n"
#test_octagon_outline
print "(octagon outline)\n"
#test_octagon_pocket
print "(polygon array)\n"
#test_polygon_array
