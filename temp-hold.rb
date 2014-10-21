#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

# - - - - - - - - - - - - - - - - - - - -
def  increasing_arc(mill, cx,cy,beg_radius, beg_angle, end_radius, end_angle, degree_inc = 1.0, depth = -0.5)
# - - - - - - - - - - - - - - - - - - - -
  print "(increasing arc)\n"
  if (beg_angle > end_angle)
    tt = beg_angle
    beg_angle = end_angle 
    end_angle  = tt
  end
  if (beg_radius > end_radius)
    tt = end_radius
    end_radius = beg_radius
    beg_radius = tt
  end

  deg = beg_angle
  degree_inc = degree_inc.abs
  radius_change = (end_radius - beg_radius).abs
  sweep = (end_angle - beg_angle).abs
  no_steps = sweep / degree_inc
  radius_change_per_deg_inc  = radius_change / no_steps
  tradius = beg_radius
  cp = calc_point_from_angle(cx,cy, deg, tradius)
  mill.move(cp.x, cp.y)
  mill.plung(depth)
  while (deg <= end_angle)
      #print "(deg = ", deg, ")\n"
       #radians = conv_degree_to_radian(tang -90)
       #new_x  = cx + Math.cos(radians) * (length)
       #new_y =  cy + Math.sin(radians) * (length)

      cp = calc_point_from_angle(cx,cy, deg, tradius)
      mill.move(cp.x, cp.y)
      deg += degree_inc
      tradius += radius_change_per_deg_inc
     
   end #while
end   # Meth


# - - - - - - - - - - - - - - - - - - - -
def  decreasing_arc(mill, cx,cy,beg_radius, beg_angle, end_radius, end_angle, degree_inc = 1.0, depth = -0.5)
# - - - - - - - - - - - - - - - - - - - -
  print "(decreasing arc)\n"
  if (beg_angle < end_angle)
    tt = beg_angle
    beg_angle = end_angle
    end_angle = tt
  end
  if (beg_radius < end_radius)
    tt = end_radius
    end_radius = beg_radius
    beg_radius = tt
  end

  deg = beg_angle
  degree_inc = degree_inc.abs
  radius_change = (end_radius - beg_radius).abs
  sweep = (end_angle - beg_angle).abs
  no_steps = sweep / degree_inc
  radius_change_per_deg_inc  = radius_change / no_steps
  tradius = beg_radius
  cp = calc_point_from_angle(cx,cy, deg, tradius)
  mill.move(cp.x, cp.y)
  mill.plung(depth)
  while (deg >=  end_angle)
      #print "(deg = ", deg, ")\n"
       #radians = conv_degree_to_radian(tang -90)
       #new_x  = cx + Math.cos(radians) * (length)
       #new_y =  cy + Math.sin(radians) * (length)

      cp = calc_point_from_angle(cx,cy, deg, tradius)
      mill.move(cp.x, cp.y)
      deg -= degree_inc
      tradius -= radius_change_per_deg_inc
     
   end #while
end   # Meth






#print "finished retract"
mill.home()
#print "finished home"



skip_this = true

if (skip_this == false)
max_diam = 2.49 / 2
interior_diam = 1.40
start_channel_width = 0.4
increase_per_rotation = 0.2

curr_diam = interior_diam
cx = 0 
cy = 2
curr_radius = interior_diam
cavity_wall_thickness = 0.15
channel_thickness = start_channel_width
# spiral from interior to the exterior increasing diameter
# as we go.
work_diam = interior_diam
bit_inc = 0.11 * 0.6

while work_diam < max_diam
  # calculate points of current arc and gradually
  # increase the points
  arc_seg_beg = 0
  arc_seg_end = 300
  deg_per_seg = (arc_seg_end - arc_seg_beg).abs
  seg_increase = curr_diam + (curr_diam * increase_per_rotation)
  increase_per_degree =seg_increase / deg_per_seg
  deg = arc_seg_beg
  tradius = curr_radius
 
  channel_offset = 0
  while (channel_offset <= channel_thickness)
    while deg < arc_seg_end
        cp = calc_point_from_angle(cx,cy, deg, tradius)
        #print "deg = ", deg, " tradius = ", tradius, "\n"
        mill.move(cp.x, cp.y)
        deg += degree_inc
        tradius += increase_per_degree
    end #while
    channel_offset += bit_inc
    deg = arc_seg_beg
    tradius = curr_radius + channel_offset
  end # while
 work_diam  += channel_thickness
 curr_radius += channel_offset
 channel_thickness += (channel_thickness * 0.2)
 channel_offset = 0

 
end #while

end  #if