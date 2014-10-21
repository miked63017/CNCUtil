#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'cncMill'
require 'cncShapeCircle'

aMill = CNCMill.new
aCircle = CNCShapeCircle.new(aMill, 1.5,1.5)
aMill.job_start()
aMill.home
aCircle.mill_pocket(1.5, 1.5, 1.0, -0.4,0.5)


# A more complex example
aMill.home()
aCircle.mill_pocket(0.0, 1.5, 2.5,  -0.75, 0.0)     #large circle
aCircle.mill_pocket(0.0, 1.5, 2.5,  -0.85, 0.75)   #large with Island
aCircle.mill_pocket(0.0, 1.5, 0.25, -0.95, 0.0)    #drill through the center

aCircle.mill_pocket(0.5, 2.0, 0.25, -0.95, 0.0)
    #drill through the edge around the center
aMill.home()

aMill.job_finish()