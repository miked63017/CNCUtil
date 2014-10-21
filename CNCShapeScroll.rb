# cncShapeScroll.rb
# Mill a scroll type compressor wheel from a solid block
# of material.   
# 
# We start at the verry center and mill a spiraling arc out
# towards the outside.
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.


require 'cncMill'
require 'cncBit'
require 'cncMaterial'
require 'cncShapeBase'
require 'cncShapeArc'
require 'cncShapeCircle'
require 'cncGeometry'




#aArr = get_arc_points(cx,cy, 90,120, 0.2)


# ************************************
class CNCShapeScroll
# ************************************
  include  CNCShapeBase
  extend  CNCShapeBase


  # - - - - - - - - - - - - - - - - - - 
  def initialize(mill,x,y,depth)
  # - - - - - - - - - - - - - - - - - - 
    base_init(mill,x,y,nil,depth)
  end #if


  # spiral from inside out
  # TODO:  Rather that futz with the formual
  # Each segmen can store the begin and end
  # outer radius for the last pass based on
  # a hash table by beg angle and the 
  # new walls can simply be wall_thickness
  # + last setting which will remove
  # the bulk of the calculating vagories.
  # - - - - - - - - - - - - - - - - - - 
  def do_mill
  # - - - - - - - - - - - - - - - - - - 
    max_diam  = 4.95
    max_radius = max_diam / 2
    shaft_support_diam = 0.55
    beg_diam  = shaft_support_diam
    shaft_diameter = 1.0 / 4.0
    beg_corr_width = 0.2
    growth_factor = 0.09 # 0.12 #0.15 #0.25
    degree_increment = 30
    wall_thick  = 0.015
    sweep       = 45.0
    curr_radius = beg_diam / 2
    curr_degree = 0.0
    curr_corr_width = beg_corr_width
    degree_inc  = 4.0
    inner_adj_factor = 1.2 #0.8 #0.7 #0.9 #1.2 #2.7 #2.1
    material_thickness = 1.0
    outer_radius_beg = curr_radius + curr_corr_width

    aCircle = CNCShapeCircle.new(mill,x,y)
    aCircle.mill_pocket(x, y, 1.0, depth,shaft_support_diam)
    mill.retract()  # mill whole for entrance 
     # of gases from prior chamber but leave
     # shaft support area

    aCircle.mill_pocket(x, y, shaft_diameter, 0 - material_thickness.abs)
    mill.retract()   # mill hole for the shaft



    while true
      end_degree  = curr_degree + sweep
      end_corr_width = curr_corr_width +  (curr_corr_width * growth_factor)

      outer_radius_end = curr_radius + end_corr_width

      inner_rad_end = curr_radius + (curr_radius * growth_factor * inner_adj_factor)

      inner_adj_factor = inner_adj_factor * 0.97

      arc_segment_pocket_adv(mill, x,y,
            curr_radius, 
            outer_radius_beg,
            curr_degree,
            inner_rad_end, 
            outer_radius_end, 
            end_degree,   
            0,
            depth,
            degree_inc)

      curr_degree += sweep
      curr_corr_width = end_corr_width

      curr_radius = inner_rad_end

      outer_radius_beg = outer_radius_end

      if (outer_radius_end > max_radius)
        break
      end #if




    end #while
  end #meth




  



  # - - - - - - - - - - - - - - - - - - 
  def do_mill_x
  # - - - - - - - - - - - - - - - - - - 
    beg_angle = 0
    end_angle = 360
    degree_inc = 5
    material_thickness = 0.8
    wall_thick   = 0.25
    #@depth = 0 - (material_thickness - wall_thick)
    bit_diam     = 0.12
    shaft_support_diam = 0.5
    min_spiral_radius = shaft_support_diam /2
    shaft_diameter = 0.25 * 0.93
    beg_corr_width = 0.70
    min_corridor = 0.15
    min_corr_diam = shaft_support_diam + 0.1
    corridor_adjust_per_revolution = 0.2

    aCircle = CNCShapeCircle.new(mill,x,y)
    aCircle.mill_pocket(x, y, 1.0, depth,shaft_support_diam)
    mill.retract()  # mill whole for entrance 
     # of gases from prior chamber but leave
     # shaft support area

    aCircle.mill_pocket(x, y, shaft_diameter, 0 - material_thickness.abs)
    mill.retract()   # mill hole for the shaft



    # Mill hex reset into shaft support for
    # hex nut.


    curr_radius = max_radius - wall_thick

    seg_beg_corr_width = beg_corr_width
    seg_end_corr_width = seg_beg_corr_width  * corridor_adjust_per_revolution
    if seg_end_corr_width <  min_corridor
      seg_end_corr_width = min_corridor
    end

    seg_beg_max_radius = max_radius + wall_thick
    seg_beg_min_radius = seg_beg_max_radius - seg_beg_corr_width
    seg_end_max_radius  = seg_beg_max_radius - (wall_thick + seg_beg_corr_width)
    seg_end_min_radius   = seg_end_max_radius - (seg_end_corr_width)


    # Change to  r1,2,r3,r4
    while true    
        #end_angle = beg_angle + 30
        #end_angle = beg_angle + 30

        if (seg_end_max_radius < min_spiral_radius)
          seg_end_max_radius = min_spiral_radius
        end #if

        if (seg_end_min_radius < min_spiral_radius)
          seg_end_min_radius = min_spiral_radius
        end #if

        arc_segment_pocket_adv(mill, x,y,
            seg_beg_min_radius, 
            seg_beg_max_radius,
            beg_angle,
            seg_end_min_radius, 
            seg_end_max_radius,
            end_angle,   
            0,
            depth,
            degree_inc)

        if seg_end_min_radius <=  min_spiral_radius
            # we have milled everything.
            break
        end

      beg_angle = end_angle

      #if (beg_angle > (360 - 30))
      #  beg_angle = 0
      #end #if
      
      seg_beg_corr_width = seg_end_corr_width
      seg_end_corr_width = seg_end_corr_width * corridor_adjust_per_revolution

      seg_beg_min_radius =  seg_end_min_radius
      seg_beg_max_radius = seg_end_max_radius

      seg_end_max_radius = seg_beg_max_radius - ((seg_beg_corr_width) + wall_thick) 
      seg_end_min_radius = seg_end_max_radius - (seg_end_corr_width)

    end # while



    mill.retract()
    mill.mill_circle_s(cx,cy, max_diam+0.15, depth*3, true)
    #aCircle.mill_pocket(cx, cy, max_diam+ 0.15,  depth, max_diam + 0.05)  # mill circle out around the scroll area.
    mill.retract
  end #meth
end # class



################
### Main Scroll test driver
################

  mill = CNCMill.new()
  circ_x            = 2
  circ_y             = 2
  aDepth         = -0.8

  aScroll = CNCShapeScroll.new(
             mill, 
             circ_x, 
             circ_y, 
             aDepth)

  aScroll.do_mill



