# 
require 'cncMill'

#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
pwidth     = 12.0
pfocus_y  = 5
mill_depth = -1.95
x_increment = 0.05

aMill  =  CNCMill.new
aMill.job_start()
aMill.home

aParab = CNCShapeParabola.new(
                 aMill, 
                 pwidth, 
                 pfocus_y, 
                 mill_depth, 
                 x_increment)

aMill.retract
aParab.do_mill()
aMill.home()
aMill.job_finish()
 