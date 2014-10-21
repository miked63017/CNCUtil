#ex_calc_distance.rb
#
# Example showing how to calculate the distance
# between too coordinate points. 
# Calc_distance always returns a positive 
# number.  
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'cncGeometry' 

aDistA = calc_distance(0.5,0.5, 1.982, 1.827)
   # Calculate the distance from a point at X of 0.5, Y 0.5 
   # to the point X 1.982 and Y of 1.827.  returns a number
   # with that distance.


aDistB = calc_distance(x1=0.5, y1=0.5, x2=3.8, y2=-1.9)
   # I favor the use of the  named parameters as shown
   # in this metho


print "aDistA =", aDistA, "\n"
print "aDistB =", aDistB, "\n"


  
