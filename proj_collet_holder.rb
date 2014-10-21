# proj_collet_holder.rb
#
# Mill out a holder for collet set and allen wrenches that come with my Taig 
# mill.   I purchased the collet set because a Mill isn't any good without
# a set of collets and a few bits.  I quickly realized that I needed a 
# decent way of keeping track of the collets after I found one rolling about
# on the floor.
# 
# At first I put them in a ziplock bag but that was always jumbled so
# the entire set ended up dumpted out on the table.    I then tried a 
# droor but then it was a pain finding the one I needed and as a result 
# they still end up spread on the work table where it is inevitable 
# that they eventually fall off and get lost
#
# This little rack was is designed to hold the basic set of collets
# in a series of holes customized for each collets size from which 
# the collets could not easily fall out even under significant 
# vibration. 
#
# The entire holder can be easily mounted on pegboard 
# or a wall.  It is a good exercise of the library and demonstrates a few 
# advanced features like Polygon / Hex pockets and circle pockets with Islands.
# as well as stopping for both a bit change and repositioning of the work.
#
# I like both my collets and my wrenches organized smallest to largest left to 
# right so I wanted to leave an island for the collets that would encourage
# placement in the ascending sequence.  I also mill the Allen wrench slots 
# so they can only hold the size they are intended for.
# 
# 
# TODO:  The Bit sub system is not working yet so when we change from 
#   bit 1 to bit 2 we did not get a change in diameter so the spiraling
#   is not working correctly.
#
#
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
#
require 'cncMill'
require 'cncShapePolygon'
require 'cncShapeCircle'
require 'cncShapeRect'


#  CONSTANTS 
Mat_x_len = 10.0  # X axis
Mat_y_len   = 1.0   # Y axis
Mat_mid_y = Mat_y_len / 2.0
C_tot_depth = 0.22
C_out_diam = 0.52
C_bot_diam = 0.41
C_bot_depth= 0.10
C_depth = C_tot_depth - C_bot_depth


# mill a single collect slot.  Uses
# the base constants for collet sizes
# all accepts paramerters that describe the 
# specific collet.
##################
def mill_collet_slot(mill, x,y, bore_diam)
##################
  aCircle = CNCShapeCircle.new(mill)

  # mill out main pocket
  aCircle.mill_pocket(x = x, 
                      y = y, 
                      diam = C_out_diam, 
                      depth= C_depth,  
                      island_diam=bore_diam)

  # mill out bottom pocket
  aCircle.mill_pocket(x = x, y = y, 
                      diam = C_bot_diam, 
                      depth = C_bot_depth,  
                      island_diam = bore_diam)
  mill.retract()

end #meth


# perform the actual milling operation.
# We mill the collets from smallest to 
# largest and then switch over and mill
# the larger allen wrench slots before
# requesting a smaller bit so that we
# can mill the smaller allen wrench holders.
# Then we request that the work block
# be turned on it's side to mill the 
# work mounting holes.
# 
# We also change the default mill X
# axis so that it starts at 0X rather
# than -7X which is the default for the
# current configuration.
#
# The material assumption is that 
# the X,Y,Z=0 are set at the front
# left top corner of the a piece
# of material which is 9 inches long
# by 1 inch wide and at least 0.75 
# inches tall.   The default speed
# assumes a relatively soft wood which
# will need to be changed if 
# a harder material such as aluminum 
# is used.
def main_mill_collet_holder
  # Wrench section
  wrench_depth = -0.5
  mill = CNCMill.new
  mill.min_x = 0.0 
    # normally min_x is set to -7.0
    # which puts 0X in the center
    # of the material. For this run
    # we are aligning 0 to the left
    # end so we have to resent our
    # minimum or we would loose 1/2
    # the movement range.
  mill.job_start()
  mill.home()
  mill.mount_bit(1, "Mount bit rotozip  0.11 diam for main milling")

  #  TODO:Convert this to a data structure to allow easier
  #  positioning for furture labeling

  xinc = 0.65
  xloc = 0.4
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.0)
  xloc += xinc
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.30)
  xloc += xinc
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.12)
  xloc += xinc
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.15)
  xloc += xinc
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.18)
  xloc += xinc
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.21)
  xloc += xinc
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.26)
  xloc += xinc
  mill_collet_slot(mill, xloc, Mat_mid_y, 0.27)
  xloc += xinc

  #  TODO:Convert this to a data structure to allow easier
  #  positioning for furture labeling


  # mill the larger hex pockets
  xinc = 0.35
  xloc += (xinc * 9.0)
  max_x = xloc
  wrench_depth = -0.5
  print "(max_x=", max_x, ")\n"
  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.20,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()

  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.18,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()

  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.13,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()


  #TODO:  Software should be smart enough to automatically request
  # smaller bit   

  # mill the smaller hex pockets
  mill.home()
  mill.mount_bit(2, "Mount bit 0.026 diam for small hex")


  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.11,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()

  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.10,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()

  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.08,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()

  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.06,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()

  mill_hex_pocket(mill = mill, cent_x = xloc, cent_y = Mat_mid_y,
        diam   = 0.06,  depth  = wrench_depth)
  xloc -= xinc
  mill.retract()




  mill.home()
  mill.pause("Turn material over for milling mounting holes | top should be towards Y 0")
  mill.mount_bit(1, "Mount bit 0.11 diam for milling mounting holdes")

  aCircle = CNCShapeCircle.new(mill)

    # mill out left mounting 
    # hole
  aCircle.mill_pocket(x = 0.2,
                      y = 0.5,
                      diam = 0.14,
                      depth= -1.0,
                      island_diam= 0)

  # Mill out right mounting 
  # hole
  aCircle.mill_pocket(x = max_x + 0.2,
                      y = 0.5,
                      diam = 0.14,
                      depth= -1.0,
                      island_diam= 0)

  # TODO:  Add code here that will allow labeling
  # in english units on front of the block.




  mill.home()
  mill.job_finish()

end #def

main_mill_collet_holder()