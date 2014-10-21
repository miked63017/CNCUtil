# test_spiral.rb

# demonstrates use of the 
# spiral shape object
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'cncMill'
require 'cncShapeSpiral'

mill  =  CNCMill.new
mill.job_start()
mill.home()

mill_spiral(
  mill,
  cent_x = 1.95,
  cent_y = 1.7,
  inner_diam = 0.45,
  outer_diam = 3.3,
  channel_thick = 0.25,
  wall_thick = 0.15,
  depth  = -0.5)

mill_spiral(
  mill,
  cent_x = 3.95,
  cent_y = 3.1,
  inner_diam = 0.15,
  outer_diam = 1.75,
  channel_thick = 0.10,
  wall_thick = 0.08,
  depth  = -1.5)


mill.home()
mill.job_finish()

