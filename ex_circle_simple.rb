#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
#
# NOTE: Anything on a line after the # symbol is a 
#       comment added to the code to help you understand
#       the example

require 'CNCMill'
   # imports the functionality of the Mill
   # which ultimatly controlls all the code
   # generation and bit positioning.

require 'CNCShapeCircle' 
   # basic circle is one of our stock shapes so
   # we just import it to gain access to it's
   # capabilities. 


#aMill = CNCMill.new("config/machine/machine-taig2014.rb", "config/material/strofoam-white.rb")
aMill = CNCMill.new()

   # creates a new milling object and
   # loads it with the configuration
   # for the Taig2014 mill which
   # includes X,Y limits, etc.  It also loads
   # up the configuration information for white
   # strofoam which allows it to automatically 
   # adjust the bit feed rates,  cut increments
   # and cutting depths to be approapriate for
   # the material.

aMill.job_start() 
   # outputs housekeeping code like %

aMill.retract()   
   # make sure bit is raise above material
   # for pockets this happens pretty much 
   # automatic but for  primitive operations
   # we left the control with you.

mill_circle_s(aMill, x=2.0,y=1.0, diam=0.75, depth=-0.5, adjust_for_bit_radius=true)
   # Mills a simple profile of a circle
   # that is centered on X of 2,  Y of 1
   # has diameter of .075 inches and will
   # mill it to a depth of 0.5 inches.  This
   # simple function does not understand multiple
   # paths through the material it has to be
   # done with one or more repeated calls each
   # one which is deeper than the previous one.

aMill.home() # return bit to home position

aMill.job_finish() # output housekeeping code
