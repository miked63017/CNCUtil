# CNCShapePolygon.rb
# Calculates objects with 1 to 1000 shapes
# centered on the specified location
# and mills those shapes.
#
# #  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

require 'CNCMill'
require 'CNCGeometry'
require 'CNCShapeBase'
# Mill a Hexagon Pocket of the specified size
# returns the polygon object created to do the
# work after the do_mill operation has been
# called.
#####################################
def mill_hex_pocket(mill, cent_x, cent_y, diam, depth=nil)
#####################################
   aPoly = CNCShapePolygon.new(mill,  cent_x,  cent_y,    nil, diam=diam, num_sides=6, depth=depth,  degree_inc=nil)
   aPoly.do_mill()
   return aPoly
end #meth


# Primitive: Mills the outline of a polygon at the specified
# diameter.   If  cutter_compensation is = true then
# it will automatically compensate for cutter 
# diameters.    This method will not properly
# handled multiple passes to reach proper depth.
# use the class method if deep pockets wit 
# multiple passess are needed.
#############################################
def mill_polygon(mill, cent_x, cent_y, diam,  
    no_sides, depth=nil, cutter_comp=false)
#############################################
  if cutter_comp == true
    diam -= mill.bit_radius
  end #if
  #mill.retract()
  side_count = 0
  curr_angle = 0.0
  radius     = diam / 2
  degree_inc = 360 / no_sides
  while (curr_angle <= 360)
      cp = calc_point_from_angle(cent_x, cent_y, curr_angle, radius)
      mill.move(cp.x, cp.y)
      if (side_count == 0)
        mill.plung(depth)
      end #if
      side_count = side_count + 1
      curr_angle += degree_inc
  end #while
end # meth


# a class that mills out polygon pockets.
# and Polygon outlines
# *****************************************
class CNCShapePolygon
# *****************************************
  include  CNCShapeBase
  extend  CNCShapeBase

  # - - - - - - - - - - - - - - - - - - 
  def initialize(mill,  cent_x,  cent_y,        start_z, diam=0.25,  num_sides=6,
  depth=nil,  degree_inc=nil)
  # - - - - - - - - - - - - - - - - - -
    #print "L66: mill= ", mill
    base_init(mill,cent_x,cent_y, start_z,depth)
    @diam = 0.25
    @degree_inc = 0.0
    @pocket_flag = true
    @island_diam = 0.0
    @num_sides   = num_sides
  end #meth


  # - - - - - - - - - - - - - - - - - -
  def degree_inc=(aNum)
  # - - - - - - - - - - - - - - - - - -
    @degree_inc = aNum
    return self
  end #if


  # mill out as a outline
  # - - - - - - - - - - - - - - - - - -
  def set_outline
  # - - - - - - - - - - - - - - - - - -
    @pocket_flag = false
    return self
  end #if


  # mill out as a pocket
  # - - - - - - - - - - - - - - - - - -
  def set_pocket
  # - - - - - - - - - - - - - - - - - -
    @pocket_flag = true
    return self
  end #if

  # mills out a polygon object that
  # has been loaded with essential data.
  # The assumption is that cutter_compensation
  # should be used to obtain a whole that exactly
  # matches specified diameter.  If the pocket
  # is deep then multiple passes will be used
  # to reach the depth.  If pocket_flag is equal
  # to true then the entire polygon will be milled
  # out but if it is false then only the outline will be milled.
  # - - - - - - - - - - - - -
  def do_mill
  # - - - - - - - - - - - - -
    mill.retract()
    target_depth = @depth
    print "(polygon do_mill target_depth=", target_depth, " mill.cut_depth_inc_curr=", mill.cut_depth_inc_curr, ")\n"
    if target_depth.abs <= mill.cut_depth_inc_curr.abs
      print "(polygon do_mill single pass cut )\n"
      do_mill_s(target_depth)
    else
      # Need multiple passes
      print "(polygon do_mill single pass cut )\n"
      tdepth = 0 - mill.cut_depth_inc_curr.abs
      print "(polygon do_mill tdepth=", tdepth, ")\n"
      while true
        print "(L121: tdepth=", tdepth, ")\n"
        do_mill_s(tdepth)
        if (tdepth == target_depth)
           break # have reached target depth
        end #if
        tdepth -= mill.cut_depth_inc_curr.abs
        if (tdepth.abs > target_depth.abs)
          # want to make sure final cut doesn't
          # go past tarteget.
          tdepth = target_depth
        end #if
      end #while
    end #else

  end #meth


  # Used by do_mill to do most of the 
  # milling.   It driectly plunges to the
  # specified depth and begins the milling
  # depending on do_mill to properly handel 
  # multi layer milling.
  # - - - - - - - - - - - - -
  def do_mill_s(tmp_depth)
  # - - - - - - - - - - - - -
    tmp_max_diam = @diam
    if (@cutter_comp == true)
      tmp_max_diam -= @mill.bit_radius
    end #if
    if @pocket_flat == false
     curr_diam = tmp_max_diam
     # we only need on circle 
     # rather than spiraling
    else
      curr_diam = bit_radius
    end #if
    while true
      mill_polygon(
        mill = @mill,
        cent_x = @x,
        cent_y = @y,
        diam   = curr_diam,
        no_sides = @num_sides,
        depth = tmp_depth,
        cutter_comp = false)
      if (curr_diam == tmp_max_diam)
        # we are done milling because
        # we got an exact match on
        # our target diameter
        break
      end
      curr_diam += mill.cut_increment
      if (curr_diam > tmp_max_diam)
        curr_diam = tmp_max_diam
      end #if
    end #while
  end  #meth



# - - - - - - - - - - - - - - - - - - - -
  def circ_array(circ_x, circ_y, radius, beg_degree=0.0, end_degree = 360.0, num_elem=6)
  # - - - - - - - - - - - - - - - - - - - -
     sweep_angle  = end_degree - beg_degree
     degree_inc   = sweep_angle  / num_elem
     curr_angle   = beg_degree 
     # illustrate an easy way to get a
     # repeating array of arc pockets
     for cc in (1..num_elem)
        cp = calc_point_from_angle(
          circ_x, circ_y, curr_angle, radius)
        @x = cp.x
        @y = cp.y
        do_mill()
        mill.retract()
        if (curr_angle >= end_degree)
           break
        end #if
        curr_angle += degree_inc
        if (curr_angle > 360)
          curr_angle = curr_angle % 360
        end #if
     end #for
  end #meth
end #class
