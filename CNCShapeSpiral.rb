# cncShapeSpiral.rb
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'CNCMill'
require 'CNCGeometry'


# produces a simple spiral out from the center
# of a circle in a gradually increasing arc until
# it reaches the specified maximum. Mill the tightest
# spiral possible allowing space for the milling
# a channel of the specified width while retaining
# a wall between channels of the specified thickness.
# - - - - - - - - - - - - - - - - - - -
def mill_spiral(
    mill,
    cent_x,
    cent_y,
    inner_diam,
    outer_diam,
    channel_width,
    wall_thick,
    depth = nil)
# - - - - - - - - - - - - - - - - - - -
  cut_inc    = mill.cut_increment
  degree_inc = 1.0
  min_radius   = inner_diam / 2.0
  max_radius   = outer_diam / 2.0
  delta_radius = max_radius - min_radius
  
  if (depth == nil)
    depth = mill.cut_depth
  end #if

  # have to allow bit radius on
  # both sides of the cutting tool
  # for cutting tool compensation

  adjusted_channel_width = channel_width - mill.bit_radius
  if adjusted_channel_width < mill.bit_diam
    # our channel can not be less than
    # one bit thick
    adjusted_channel_width = mill.bit_diam
  end #if

  channel_start_max_radius = (min_radius + channel_width) - mill.bit_radius

  no_passes  = (adjusted_channel_width / cut_inc) + 1.0
  usage_per_circle = (channel_width + wall_thick) * 1.05
  increase_per_degree = usage_per_circle / 360

  #print "(mill_spiral no_passes=", no_passes, " usage_per_circle = ", usage_per_circle, " increase per degree=", increase_per_degree, " min_radius=", min_radius,  " max_radius=", max_radius, " cut_inc = ", cut_inc," tool adjusted channel_width=", adjusted_channel_width, ")\n"

  pass_beg_radius = min_radius + mill.bit_radius
  pass_max_radius = (max_radius - channel_width) + mill.bit_radius



  passcnt = 0
  while (true)
    # one pass here for each width
    # of the bit we need to make
    curr_radius = pass_beg_radius
    deg = 0.0

    # Move the head to start of the spiral
    mill.retract()
    first_point = calc_point_from_angle(cent_x, cent_y, deg, curr_radius)
    mill.move(first_point.x, first_point.y)
    mill.plung(depth)

    while curr_radius <= pass_max_radius
       # mill a single pass of the 
       # spiral
       aPoint = calc_point_from_angle(cent_x, cent_y, deg, curr_radius)
       mill.move(aPoint.x, aPoint.y)
       curr_radius += increase_per_degree
       deg += 1.0
       if (deg >= 360)
         deg = 0
       end #if

    end #while
    if (pass_beg_radius >= channel_start_max_radius)
      # our last pass was our final
      # for the specified channel width
      break
    elsif (pass_beg_radius + cut_inc) > channel_start_max_radius
      # one more cut increment will put us over the
      # the max channel width so we adjust the cut_inc
      # down so the last pass takes off just enough
      cut_inc = channel_start_max_radius - pass_beg_radius
    end #if
    pass_beg_radius += cut_inc
    pass_max_radius += cut_inc
  end # for
end #meth


