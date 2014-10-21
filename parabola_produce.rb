require 'cncMill'
require 'cncShapeParabola'
#  parabola_produce.rb
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

opt=6
aMill  =  CNCMill.new
aMill.job_start()
cut_off_sides = false

if opt == 1
  pwidth     =  12.0
  pfocus_y  =   1.5
  mill_depth = -2.02
  x_increment = 0.05
  aim_hole_diam = 5.0/8.0
  aMill.max_y = 4.1
  aMill.curr_bit.adjust_speeds_by_material_type("foam")
  cut_off_sides = false
end


if opt == 2
  print "(9.5 wide with 1.45 aim to keep 1/2 hole below edge of rim)"
  pwidth     =  9.5
  pfocus_y  =   1.45
  mill_depth = -1.52
  x_increment = 0.1
  aim_hole_diam = 5.0/8.0
  aMill.max_y = 4.1
  aMill.curr_bit.adjust_speeds_by_material_type("foam")
  cut_off_sides = false
end

if (opt == 3)
  print "(13 wide with 1.52 deep aim to force top of aim hole below edge of parabola curve)\n"
  pwidth    =  13
  pfocus_y  =   2.2
  mill_depth = -1.52
  x_increment = 0.1
  aim_hole_diam = 5.0/8.0
  aMill.max_y = 4.1
  aMill.curr_bit.adjust_speeds_by_material_type("foam")
  cut_off_sides = false
end

if (opt == 5)
  print "(Thinner setup for wood frame)\n"
  print "(Set mill so 0Y leaves at least 1/2 inch of material material)\n"
  print "(To make wood support mold move the Y focus point in enough to leave at least 1/2)\n"
  print "(inch of material in front of the parabola.  The wood support requires material less)\n"
  print "(less than 1/2 inch thick to fit under the Z axis brace on taig)\n"
  print "\n"
  pwidth    =  13
  pfocus_y  =   2.7
  mill_depth = -0.85
  x_increment = 0.1
  #aim_hole_diam =  (5.0/8.0) + 0.02
  aim_hole_diam =  0.245
  aMill.max_y = 4.1
  aMill.curr_bit.adjust_speeds_by_material_type("particle_board")
  cut_off_sides = false
end


if (opt == 6)
  print "(Thinner setup for wood frame)\n"
  print "(Set mill so 0Y leaves at least no material in Y front because we need full depth)\n"
  print "(of machine for this focus depth )\n"  
  print "\n"
  pwidth    =  13
  pfocus_y  =   5.0
  mill_depth = -0.50
  x_increment = 0.1
  aim_hole_diam =  0.245
  # USE MACHINE DEFAULT MAX Y aMill.max_y = 5.35
  aMill.curr_bit.adjust_speeds_by_material_type("particle_board")
  cut_off_sides = false
end



  print "(Produce Parabola ", sprintf("%8.3f",pwidth), " inch wide  with focus "
  print pfocus_y
  print " inches above center of parabola.   Cut material ", sprintf("%8.3f", mill_depth), ")\n"
  print "(Basic parabola shape with focus point used for end plates or drape mold)\n"  
  print "(Focus point is on Y access positive Y when cutting starts at zero-y at edge of sheet)\n"
  print "(Cut depth of ", sprintf("%8.3f", mill_depth), ")\n"
  print "(Set X to center of material and Y to very from edge.  All Y are cut in +Y direction)\n"
  print "(Set CutDepthIncrement to a smaller number if cutting materials harder than styrofoam)\n"
  print "(Will trim the sides.  In general the material needs to be at least several inches)\n"
  print "(greater in the Y diameter than the focal point)\n"
  print "\n\n"  
  aMill.home
  aParab = CNCShapeParabola.new(
                 aMill, 
                 pwidth, 
                 pfocus_y, 
                 mill_depth, 
                 x_increment, 
				 aim_hole_diam,
				 cut_off_sides)
  aMill.retract
  aParab.do_mill_end_plate_pattern()
  aMill.home()
  aMill.job_finish()
 
  
 
 
