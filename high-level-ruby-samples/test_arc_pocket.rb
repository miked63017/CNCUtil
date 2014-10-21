require 'cncMill'
require 'cncShapeArc'
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
# demonstrate simple use of a arc pocket
# - - - - - - - - - - - - - - - - - - - -
def arc_test_0
# - - - - - - - - - - - - - - - - - - - -
  #############
  ### ARC TEST #0
  #############
  aMill = CNCMill.new
  aMill.job_start()
  aMill.home()
  #  variables used here to make
  #  easy for reader.

  aRes = arc_segment_pocket(
     mill = aMill, 
     circ_x  = 1.0,
     circ_y  = 1.0,
     min_radius = 0.82,
     max_radius = 0.95,
     beg_angle  = 41.0,
     end_angle  = 48.3,
     0,
     depth      = -1.8,
     degree_inc = 0.5)
     
  return aRes
end #meth


# An easy circular array of Arch segments.
# is made by defining the first semgment where
# it needs to be and then calling circ_array
# rather than do_mill.  circ_array has an 
# option of specifiying the number of elements
# and / or the number of degrees between elements.
# The array always starts with the first element and
# works it's way clockwise until it has supplied 
# the number of elements requested.
# - - - - - - - - - - - - - - - - - - - -
def arc_test_easy_array(mill)
# - - - - - - - - - - - - - - - - - - - -
   aArc = CNCShapeArc.new(
       mill = mill, 
       x = 1.5,
       y = 1.5,
       beg_min_radius = 0.65, 
       beg_max_radius = 0.85,
       beg_angle  = 0.0, 
       end_min_radius = 0.65,
       end_max_radius = 0.90,
       end_angle      = 35.0,  
       depth          = -0.2)

   aArc.circ_array()
end #meth
  

# demonstrate simple use 
# which forces the pocket
# to be the same width
# all the way across the arc.
# This example also shows how to 
# make a circular array of arc 
# segments.
# - - - - - - - - - - - - - - - - - - - -
def arc_test_manual_array(mill = nil)
# - - - - - - - - - - - - - - - - - - - -
  #############
  ### ARC TEST #0
  #############
  if (mill == nil)
    mill = CNCMill.new
    mill.job_start()
    mill.home()
  end #if

    #  variables used here to make
    #  easy for reader.
    circ_x = 3.0
    circ_y = 2.0
    min_radius =  0.7
    max_radius = 0.95
    beg_angle   = 0
    degree_inc =  4
    depth          = -0.5
    sweep_angle = 30
    width  = 0.1

    curr_beg_angle   = beg_angle
    lc =0
    curr_min_radius = min_radius
    # illustrate an easy way to get a 
    # concentric wrings of arc pockets
    while (lc < 3)
       max_radius = curr_min_radius + width
       curr_beg_angle   = beg_angle
       lc += 1
      # illustrate an easy way to get a
      # repeating array of arc pockets
      cc = 0
      while (cc < 4)
        cc += 1
        end_angle = curr_beg_angle + sweep_angle
        aRes = arc_segment_pocket(mill, 
            circ_x,
            circ_y,
            curr_min_radius, 
            max_radius,
            curr_beg_angle,
            end_angle,  
            0, 
            depth,
            degree_inc)
         mill.retract()
         curr_beg_angle = end_angle +  (sweep_angle * 0.8)
      end #while
      width = width * 1.2
      curr_min_radius = max_radius + (width * 2)
    end #while
    return aRes
end #meth



# Demonstrate advanced use
# which allows one end of the 
# pocket to be wider that the other
# - - - - - - - - - - - - - - - - - - - -
def arc_test_2(mill = nil)
# - - - - - - - - - - - - - - - - - - - -
  #############
  ### ARC TEST #1
  #############
  if (mill == nil)
    mill = CNCMill.new
    mill.job_start()
    mill.home()
  end #if

    cx = 3
    cy = 2.5
    seg_beg_min_radius = 1.0
    seg_beg_max_radius = 1.1
    seg_end_min_radius = 0.9
    seg_end_max_radius = 2.4
    beg_angle = 230
    end_angle = beg_angle + 80
    degree_inc = 3
    depth        = -1.5

      aRes = arc_segment_pocket_adv(mill, cx,cy,
          seg_beg_min_radius, 
          seg_beg_max_radius,
          beg_angle,
          seg_end_min_radius, 
          seg_end_max_radius,
          end_angle, 
          0,  
          depth,
          degree_inc)
  return aRes
end #meth








###########################
### MAIN TEST
###########################
  mill  =  CNCMill.new
  mill.job_start()
  mill.home()

  #arc_test_0(mill)

  #arc_test_easy_array(mill)


  #arc_test_manual_array(mill)

  arc_test_2(mill)
