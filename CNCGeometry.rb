# cncGeometry.rb
#
#
#  A set of Geometry and Calculas functions used to calculate  things like Polar Rectangular 
#  to   X,Y coridinates to walk around circles,  to calculate the points of a curve, etc.
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

require 'CNCPoint'
require 'CNCExtent'
include Math

# Used these contstances to save a division 
# when converting from Degrees to radians
Radian_to_degree_mult =  180.0 /  PI;
Degree_to_radian_mult =  PI / 180.0;



# makes sure our number is a float object
# because some operations fail when a 
# integer is used where float was expected.
# - - - - - - - - - - - - - - - - - -
def to_f(aNum)
# - - - - - - - - - - - - - - - - - -
  return 0.0 + aNum
end #meth



#  Conver a number in degrees to radians.
#  this is used by most angle calculation functions
#  because they expect input in radian and 
#  produce output in radians whereas Joe
#  normally works in degrees.
#  original formual from Google.
#    //Dim radians As Double = ((angle + rotation + 360) Mod 360) * Math.PI / 
# - - - - - - - - - - - - - - - - - - - -
def conv_degree_to_radian(aNum)
# - - - - - - - - - - - - - - - - - - - -
  return (aNum * Degree_to_radian_mult)
end #meth


# Convert a number in radians 
#  to degrees.
# - - - - - - - - - - - - - - - - - - - -
def conv_radian_to_degree(aNum)
# - - - - - - - - - - - - - - - - - - - -
  return (aNum * Radian_to_degree_mult)
end


# Return the slope of a line where the number returned
# is the change of X divided by the change of 
# y.    
# If   Y  did not change then the slope
# is 0.
#Accept a line description between two points 
# and return
# the rise over run for that line.
# - - - - - - - - - - - - - - - - - - - -
def calc_slope(x1, y1,  x2, y2)
# - - - - - - - - - - - - - - - - - - - -
   if (y1 == y2)
     return 0
   end #if
   dy = (y2 - y1) * 1.0
   dx = (x2 - x1) * 1.0
   slope = dx / dy
   return slope
end #meth



# returns distance between two points.
# uses pythagreans therom to calculate
# the distance between two points on
# a grid.   Can also be used to calculate
# radius of a circle when the location of
# the center and one point on the 
# perimiter is known.
# - - - - - - - - - - - - - - - - - - - -
def calc_distance(x1,y1, x2,y2)
# - - - - - - - - - - - - - - - - - - - -
   if (x1 == x2) && (y1 == y2)
      c = 0
   else
      a = (x1 - x2).abs  * 1.0
      b = (y1 - y2).abs  * 1.0
      csqd = (a*a) + (b * b)
      c = Math.sqrt(csqd)
   end # else
   return c
end #meth



#  WARNING:  Polar coordinates will return
#    a number with is relative to the X axis not
#    the Y axis.   So you have to start your
#    circle on 0 degree line.   Polar coordinates
#    do not take into account which side of the
#    Y axis they are on so the angle is always 
#    relative to the X axis.
# - - - - - - - - - - - - - - - - - - - -
def conv_xy_to_polar(x,y)
# - - - - - - - - - - - - - - - - - - - -
   if (x == 0)
    if (y >= 0)
      return 0
    else
      return 180
    end #else
  elsif (y == 0)
    if (x2 >= 0)
      return 90
    else
      return 270
    end #else
   end #else

   x = x + 0.0
   y = y + 0.0
   dist =  Math.sqrt((x*x) + (y*y))
   slope = y / x
   aradian = Math.atan(slope)
   degrees = conv_radian_to_degree(aradian)   
   print "degrees before adj=", degrees,"\n"
   if (x > 0)
     if (y > 0)
       # Quadrent 1;
       degrees =  degrees
     else
      # Quadrent 2
      degrees = 90 - degrees
     end # else
   else
     if (y < 0)
       #Quadrent 3
       degrees = 270 - degrees
     else
      # must be Quadrent 4
      degrees = 270 - degrees
     end # else
   end #else
   pp = CNCPolar.new(dist, degrees)
   return pp
end #meth


# - - - - - - - - - - - - - - - - - - - -
def conv_polar_to_xy(distance,  angle_deg)
# - - - - - - - - - - - - - - - - - - - -
    if (angle_deg > 360) 
      angle_deg = angle_deg % 360
    end #if
    #print "angle_deg=", angle_deg, "\n"

    quad = 1
    tang = angle_deg
    if (angle_deg > 90)
      quad = 2
      tang  -= 90
    elsif (angle_deg > 180)
      quad = 3
      tang -= 180
    elsif (angle_deg > 270)
      quad = 4
      tang -= 180
    end #else
    #print "tang=", tang, "\n"
    #print "quad=", quad, "\n"
    angle_rad = conv_degree_to_radian(tang)
    x =  distance * Math.cos(angle_rad)
    y =  distance * Math.sin(angle_rad)
    #print "before adjust x=", x,  " y=", y, "\n"
     case quad
       when 1
          # nothing needs to be done
       when 2
          # x is ok
          y = 0 - y
       when 3
          x = 0 - x
          y = 0 - y
       when 4
          x = 0 - x
     end
    pp = CNCPoint.new(x,y)
    return pp
end # meth


# - - - - - - - - - - - - - - - - - - - -
def polar_to_xy_(aPolar)
# - - - - - - - - - - - - - - - - - - - -
    return conv_polar_to_xy(aPolar.dist,  aPolar.angle)
end # meth


#### When viewing this as a triangle.  The
#### alt function appears to return the 
#### top angle while the main calc_angle 
#### returns the bottom angle assuming the
#### third angle is a right angle.
#### - - - - - - - - - - - - - - - - - - - -
###def calc_angle_alt(x1, y1,  x2, y2)
#### - - - - - - - - - - - - - - - - - - - -
###   dx = (x2 - x1) 
###   dy = (y2 - y1) 
###   dx = (x2 - x1) 
###   atr = Math.atan2(dx,dy)
###   top_angle  = conv_radian_to_degree(atr)
###   quad_adjust = calc_circle_quadrent_degree_adjust(x1,y1,x2,y2)
###   bottom_angle = quad_adjust  +  top_angle
###    print "dist from x=", x1,  " y=", y1,  "  to  x=", x2,  " y=", y2, " = ", calc_distance(x1,y1,x2,y2), "\n"
###    print "dx=", dx, " dy=", dy,  " atr=", atr,  "quad_adjust = ", quad_adjust,   " top_angle=", top_angle,  "  bottom_angle = ", bottom_angle, "\n"
###    aPolar = conv_xy_to_polar(dx,dy)
###    print "aPolar=",  aPolar.to_s,  "\n"
###   return top_angle
###end # meth
###


# assuming a a circle with the center at X1,Y1 
# and 0 / 180 degrees on the Y Axis where 
# 0 degrees is the top then 
# calculate the angle relative to this 0,0 for
#the a given point (x2,y2) that is assumed
#to be on the perimiter of the circle.  
#  WARNING:  This will not return polar coordnates
#     because those are calculated relative to the
#     X axis.
# - - - - - - - - - - - - - - - - - - - -
def calc_angle(x1, y1,  x2, y2)
# - - - - - - - - - - - - - - - - - - - -
  if (x1 == x2)
    if (y2 >= y1)
      return 0
    else
      return 180
    end #else
  elsif (y1 == y2)
    if (x2 >= x1)
      return 90
    else
      return 270
    end #else
  else
    x1 = x1 + 0.0 # force to be floating point
    x2 = x2 + 0.0 # force to floating point
    slope =  (y2-y1) / (x2-x1)
    radians =   Math.atan(slope)
    degrees = conv_radian_to_degree(radians)
    #  Handle Adjusting Quadrent
    if ((x2 > x1) && (y2 > y1))
      # Quadrent 1;
      degrees =  degrees
    elsif ((x2 > x1) && (y2 < y1))
     # Quadrent 2
     degrees = 90 - degrees;
    elsif ((x2 < x1) && (y2 < y1))
     # Quadrent 3
     degrees = 270 - degrees
    else
     # must be Quadrent 4
     degrees = 270 - degrees
    end # else
  end # else
  return degrees
end  # method


# rotate point x,y around 0,0 axis by theta
# theta degrees where theta is the number
# of degrees to rotate by and return a new 
# point with the newly calculated x,y locations.
# - - - - - - - - - - - - - - - - - - - - - - - - - -
def calc_point_rotated_relative(x,y, theta)
# - - - - - - - - - - - - - - - - - - - - - - - - - - -
  theta = conv_degree_to_radian(theta)
  xr= Math.cos(theta)*x - Math.sin(theta)*y 
  yr = Math.sin(theta)*x + Math.cos(theta)*y 
  pRes = CNCPoint.new(xr,yr)
end # meth

# for a circle centered on cirX, cirY with a 
# point px,py which is at pdegree on the 
# perimiter of the circle calculate a new 
# x,y point 
# - - - - - - - - - - - - - - - - - - - - - - - - - -
def calc_point_rotated_abs(x,y, angle)
# - - - - - - - - - - - - - - - - - - - - - - - - - -
   curr_angle = calc_angle(0,0,x,y)
   rel_amt =  angle - curr_angle
   return calc_point_rotate_relative(x,y,rel_amt)
end # meth



def rotate_object
#ROTATION
#   In order to rotate a object you need to know it's x, y, z positions and how 
#   many degrees you are going to rotate it by.
#      
#   Rotation around the z axis:
#     sub rotation_Z
#         x% = x% * cos(angle%) - y% * sin(angle%)
#         y% = y% * cos(angle%) + x% * sin(angle%)
#     end sub
#
#   Rotation around the x axis:
#     sub rotation_X
#         y% = y% * cos(angle%) - z% * sin(angle%)
#         z% = z% * sin(angle%) + z% * cos(angle%)
#     end sub
#
#   Rotation around the y axis:
#     sub rotation_Y
#         z% = z% * cos(angle%) - x% * sin(angle%)
#         x% = z% * sin(angle%) + x% * cos(angle%)
#     end sub
end



  # Calculate the X,Y location of a point relative 
  # to the center of circle.  Where that point is
  # rotated around the circle by angle degrees.
  # and is length long.
  # for a circle centered on cirX,cirY with a specified
  # radius calculate the X,Y coordinate of a point
  # the specified number of degrees around the circle
  # - - - - - - - - - - - - - - - - - - - - -
  def calc_point_from_angle(cx, cy, angle,  length)
  # - - - - - - - - - - - - - - - - - - - - -
    #System.Convert.ToInt32(System.Convert.ToDouble(originX) * Math.Cos(radians)), originY + #System.Convert.ToInt32(System.Convert.ToDouble(originY) * Math.Sin(radians)))
    # radians = (90 - angle) * degree_to_radian;
    if (angle > 360) 
      angle = angle % 360
    end #if
    #print "(cx=", cx, "  cy=", cy, "  angle=",  angle,  ",   length=", length, ")\n"

    #if (angle > 360)
     # angle = angle % 360.0

    
    quad = 1
    tang = angle

##    if (angle == 9999)
##    if (angle == 0)
##      return CNCPoint.new(cx, cy - length)
##    elsif (angle == 90)
##      return CNCPoint.new(cx + length, cy)
##    elsif(angle == 180)
##      return CNCPoint.new(cx, cy - length)
##    elsif (angle == 270)
##      return CNCPoint.new(cx - length, cy)
##    elsif(angle == 360)
##      return CNCPoint.new(cx, cy - length)
##    elsif (angle > 90)
##      quad = 2
##      tang  -= 90
##    elsif (angle > 180)
##      quad = 3
##      tang -= 180
##    elsif (angle > 270)
##      quad = 4
##      tang -= 180
##    end #else
##    end # 99999
##     #print "tang = ", tang,  " quad=", quad, "\n"
##

     radians = conv_degree_to_radian(tang -90)


     new_x  = cx + Math.cos(radians) * (length)
     new_y =  cy + Math.sin(radians) * (length)

     #print "(new_x = ", new_x, "  new_y=", new_y, ")\n"
##
##   if (angle == 9999)
##    case quad
##       when 1
##          # nothing needs to be done
##       when 2
##          # x is ok
##          #new_y = 0 - new_y
##       when 3
##          new_x = 0 - new_x
##          new_y = 0 - new_y
##       when 4
##          new_x = 0 - new_x
##     end
##  end # 9999
##

     aRes = CNCPoint.new(new_x, new_y)
     return aRes
  end # meth

# Calculate the number of points specified between the start and stop
# angle and return an array of point containing those coordinates.
# - - - - - - - - - - - - - - - - - - - - -
def calc_points_for_arc(cx, cy,radius=1.0, beg_angle=0, end_angle = 360, degree_inc = 1.0)
# - - - - - - - - - - - - - - - - - - - - -
  if beg_angle > end_angle
    #swap if starting point is higher than ending point
    tt = beg_angle
    end_angle = beg_angle
    beg_angle = tt
  end #if
  res = Array.new
  curr_angle = beg_angle
  #p2 = calc_point_rotated_relative(p2.x, p2.y,1)
  #print "angle_inc = ", angle_inc, "\n"
  #print "pp = ", pp, "\n"
  
  start_point = calc_point_from_angle(0,0,beg_angle, radius)
  last_point = start_point 
  res.append(start_point)
 
  # sets up the change of the 
  stop_angle = end_angle
  if (end_angle == 360) && (beg_angle == 0)
    stop_angle -= 1
  end #if

  cnt = 1
  #print "   relative rotate point = ", p2, "\n"
  while (curr_angle <= stop_angle)
     curr_angle  += angle_inc
     p2 = calc_point_rotated_relative(last_point.x, last_point.y, angle_inc)
     print "   relative rotate point = ", p2, "\n"
     res.append(p2)
     last_point = p2
  end
  return cnt
end #meth


# return a point filled in with the center x,y,c 
# for a given array.  This actually does the same
# amount of work as the calc_extents but throws
# away the min/max information so if that information
# is needed then use the calc_extents function
# instead.
def calc_center_point(aArray)
end #meth


# return a filled in extents object for an array
# that contains the min_max x,y,z  along with the
# center x,y,z for the array.   This is used to calculate
# the rotation axis for that array.
def calc_extents_for_array(aArray)
end #meth


# walk across an array of points and adjust their X,Y locations as rotated around 
# their center point.
  # - - - - - - - - - - - - - - - - - - - - -
def rotate_array(aArray, off_x,  off_y, rel_angle, change_in_place=false)
  # - - - - - - - - - - - - - - - - - - - - -
end


# Return an array of points for an arc segment
# starting at beg_angle and ending at end_angle
# with the specified radius.
# - - - - - - - - - - - - - - - - - - - -
def  get_arc_points(cx,cy,radius, beg_angle, end_angle, degree_inc = 1.0)
# - - - - - - - - - - - - - - - - - - - -
  deg = beg_angle
  degree_inc = degree_inc.abs
  ares = Array.new
  while (deg < end_angle)
      #print "(deg = ", deg, ")\n"
      cp = calc_point_from_angle(cx,cy, deg, tradius)
      ares.append(cp)
      deg += degree_inc
   end #while
end


# A re-ocurring problem is calculating the degrees
# needed at a given distance to provide an adequate
# space.  This is required for fans and spirals
# where if a common number of degrees is used for
# larger radius we wind up with large gaps fan blades
#   #   #   #   #   #   #   #   #   #
def degrees_for_distance(radius, desired_distance)
#   #   #   #   #   #   #   #   #   #
  degree_inc = 0.01
  last_degree_inc = degree_inc
  if (radius == 0)
    return nil
  end
  ci = calc_circumference(radius)
  ratio = desired_distance / calc_circumference(radius)
  answer = 360 * ratio
  return answer
   
  #cp = calc_point_from_angle(0,0,  0, radius)
  #cp2 = calc_point_from_angle(0,0, 1.0, radius)
  #dist_for_single_degree = calc_distance(cp.x,cp.y, cp2.x,cp2.y)
  #num_degrees_fit_in_distance = desired_distance / dist_for_single_degree
  #return num_degrees_fit_in_distance
end # meth


def calc_circumference(radius)
  return  Math::PI * radius * 2.0
end

# determine how many inches along the circumfrence
# of a circle one degree would be.  The Geometry 
# formula is Circumrence =  2PIR
def calc_inches_per_degree(radius)
  if (radius == 0)
    return 0
  else
    return calc_circumference(radius) / 360.0
  end
end

