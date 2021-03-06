require 'CNCMill'
require 'CNCShapeRect'
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
aMill   =  CNCMill.new
aMill.job_start()
aMill.home
aRect =  CNCShapeRect.new(aMill, 1.0,1.0, 0.25, 0.25, -0.99)
aRect.centered()  # forces to center over x,y
aRect.do_mill()
aMill.retract()

# mills a new rectangle centered over the specified
# coordinates.
aRect.centered(2.0,2.0, 2.0, 1.1, -0.43)
aRect.do_mill()
aMill.retract()

# mills specificially between the upper and
# lower specified coordinates.
aRect.reset(0,0, 0.5, 1.5,-0.2)
aRect.do_mill()
aMill.retract()

aMill.home()
aMill.job_finish()
