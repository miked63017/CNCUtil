# test_arc_pocket_spiral.rb

require 'cncMill'
require 'cncShapeArc'
require 'cncShapeArcPocketAdv.rb'

#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

# TODO: JOE RETEST THIS

# produces a simple spiral out of 
# increasing arc segments
# - - - - - - - - - - - - - - - - - - -
def arc_test_3(mill)
# - - - - - - - - - - - - - - - - - - -
  circ_x = 2.5
  circ_y = 1.5
  beg_angle = 0
  end_angle = 360
  beg_radius = 0.2
  cut_inc = mill.bit_diam * 0.6
  cc = 0
  depth = -0.2
  max_radius = 2.0
  wall_thick = 0.13
  degree_inc = 2.0
  channel_width = 0.2
  no_passes = channel_width / mill.bit_radius

  # have to allow bit radius on
  # both ends
  channel_width -= mill.bit_diam

  while cc < no_passes
    curr_radius = beg_radius + (cc * cut_inc)
    while (true)
       tmp_max_radius = curr_radius * 1.2 
       tmp_max_radius +=  (wall_thick + cut_inc * no_passes)

       if (tmp_max_radius > max_radius)
         break
       end #if
	   	   

       arc_pocket_adv(
          mill, 
          circ_x,
          circ_y, 
          curr_radius,    
          tmp_max_radius, 
		  beg_angle, 
		  curr_radius,
		  tmp_max_radius,
          end_angle, 
          depth,  
          degree_inc)

       max_delta = tmp_max_radius - curr_radius
       curr_radius = tmp_max_radius
    end #while
    mill.retract()
    cc += 1
  end # while
end #meth




###########################
### MAIN TEST
###########################
  mill  =  CNCMill.new
  mill.job_start()
  mill.home()

  arc_test_3(mill)


