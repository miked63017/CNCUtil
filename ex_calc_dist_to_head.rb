#ex_calc_dist_to_head.rb
#
# Example showing how to calculate the distance
# from the current milling head position 
# to another specified point.
#
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'cncMill'

mill = CNCMill.new
aDist = mill.calc_distance(
         mill.cx,
         mill.cy,
         1.982,
         1.827)


print "aDist #0=", aDist, "\n"
   # Long version where all 4 points are 
   # supplied.


aDist = mill.calc_distance(1.387, 1.985) 
print "aDist #1=", aDist, "\n"
  # short hand version which automatically
  # uses the mills current x and current y
  # position as one set of coordinates.


aDist = mill.calc_distance(
          x1=1.1, 
          y1=1.23,
          x2=1.99,
          y2=3.45) 
print "aDist #2=", aDist, "\n"
  # this version of the call provides 
  # better documentation for future
  # reference especially if you are
  # passing in hard coded parameters.   



# Calc_distance always returns a positive 
# number.  There is another function that 
# can return the angle between these points.  
#
# There is also a version of calc_distance
# in cncGeometry which does not require 
# a mill object to work. It however
# knows nothing about the current X and Y 
# so you always have to supply all for 
# coordinates.

