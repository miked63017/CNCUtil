require 'cncMill'
require 'cncShapeCircle'
require 'cncShapeDShaft'

#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

if (1 == 1)
  tDepth = -0.185
  tMaterial = "acrylic"
else
  tMaterial = "foam"
  tDepth    = -0.3
end


aMill = CNCMill.new()
aMill.job_start()
aMill.home()
aMill.load_bit("config/bit/carbide-0.1875X0.50X1.5-2flute.rb", "Please place 3/16 bit and adjust for 0.5 on Z to surface", 0.5, tMaterial)
aCircle = CNCShapeCircle.new(aMill, 1.5,1.5)
aMill.home()

#aCircle.mill_pocket(1.5, 1.5, 1.0, -0.4,0.5)

# Test the shape and size of an axel
aMill.retract()
aCircle.mill_pocket(0.2, 0.2, 0.25, tDepth, 0)
aMill.retract()
mill_DShaft(aMill, x = 0.6,y=0.20, diam=0.25, beg_z=0.0, end_z= tDepth, adjust_for_bit_radius=true)    
aMill.retract()
# Two sided flat shaft - Designed to help prevent wobble by different weight distribution
mill_DDShaft(aMill, x = 1.4,y=0.60, diam=0.70, beg_z=0.0, end_z= tDepth, adjust_for_bit_radius=true)    
aMill.home()


# A more complex example
#aMill.home()
#aCircle.mill_pocket(0.0, 1.5, 2.5,  tDepth, 0.0)    #large circle
#aCircle.mill_pocket(0.0, 1.5, 2.5,  tDepth, 0.75)   #large with Island
#aCircle.mill_pocket(0.0, 1.5, 0.25, tDepth, 0.0)    #drill through the center

#aCircle.mill_pocket(0.5, 2.0, 0.25, -0.95, 0.0)
    #drill through the edge around the center
aMill.home()
aMill.retract(1)

aMill.job_finish()