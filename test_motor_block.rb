# test_motor_block.rb
# 
# Produces the main motor block for Tesla Engine
#
# test a motor block for CNC mill
#
# By Joseph Ellsworth of XDOBS.COM LLC  2005-2006 Changes
# and enhancments available at our standard consulting rates.
# Free for use by all - No warranty,  No Claims, No Charges.
# No Liability, Free to change
# Free to re-distribute under any terms.
# Written in the Ruby Programming Language. which is available
# for free download from http://ruby.org
# Updates available at   http://cncutil.org
# Reserve the right to change distribution rights in
# future versions but versions prior to that time will retain 
# the old rights.
#  See (C) notice in license.txt for license and copyright.


require 'cncMill'
require 'cncShapeCircle'
require 'cncShapeRect'
require 'cncShapeArc'
require 'cncGeometry'

width = 4.0
length = 4.0
height = 1.0
offset = 0.3
depth = -1.0
diam  = 0.25
pocket_x        = 2.5
pocket_y        = 2.5
pocket_diam   = 2.5
pocket_depth = -0.85
island_height   = -0.10

aMill = CNCMill.new
aCircle = CNCShapeCircle.new(aMill)

aMill.job_start
aMill.home

#aCircle.mill_pocket(pocket_x, pocket_y,  #pocket_diam,-0.85, pocket_diam - 0.4) 
#                               X             Y            DIAM         DEPTH    ISLAND


aCircle.mill_pocket(pocket_x,  pocket_y,  0.65,   -0.75)
                         #    X             Y          DIAM  DEPTH
aCircle.mill_pocket(pocket_x, pocket_y,  pocket_diam, -0.85, 0.65) 
aCircle.mill_pocket(pocket_x, pocket_y,  0.5,  -0.90)
aCircle.mill_pocket(pocket_x, pocket_y, 0.25, -1.0, 0.0)    
aMill.retract

#The Tesla motors need a place in the center for the exhaust air to exit. 
#We will bore these out now.    We could also use the circular array or rotate 
# an object by degrees.    Our center island is 0.65 inches wide centered over
# X1.5"and Y2.5" so to clear the island we must move at least 0.325" away 
# from the center.  I use rectangles here only to show how they work but
# would normally use a series of arcs to optimize air flow.
aRect = CNCShapeRect.new(aMill)
aRect.reset(pocket_x - 0.45, pocket_y - 0.3,  pocket_x - 0.60, pocket_y + 0.3, depth)
aRect.do_mill.retract
aRect.centered(pocket_x + 0.55,  pocket_y,  0.15,  0.5, depth).do_mill.retract
aRect.centered(pocket_x,  pocket_y - 0.55,  0.5, 0.15, depth).do_mill.retract
aRect.centered(pocket_x,  pocket_y + 0.55,  0.5, 0.15, depth).do_mill.retract




# Drill the holes at each corner that will be used to bolt on the lid and to bolt this portion of the motor to the next portion. 
aCircle.mill_pocket(offset, offset, diam, depth)
aMill.retract
aCircle.mill_pocket(width - offset,  offset, diam, depth)
aMill.retract
aCircle.mill_pocket(width - offset,  (length - offset),  diam,  depth)
aMill.retract
aCircle.mill_pocket(offset, (length - offset), diam, depth)
aMill.retract()
aMill.retract()

# The last step is to mill out the feed area that allows high velocity gas or fluid flow into the motor 
# compartment and aims it in a way that maximized the energy transfer.       
# This needs to approximate a rocket nozzle shape to cause the input flow to 
# accelerate as it enters the motor compartment.
aMill.retract
pr = pocket_diam / 2 
pxe =  pocket_x - pr

px1 = pxe + 0.05
py1 = pocket_y
px2 = pxe - 0.8
py2 = pocket_y - 1
px3 = 0.4
py3 = 0.5
px4 = 1.6
py4 = 0.5
px5 = pxe - 0.45
py5 = pocket_y - 1.2
px6 = pxe - 0.0200
py6 = pocket_y - 0.15

if false
aMill.plung(-0.5)
aMill.move(px1,py1)
aMill.mill_arc(px4,py4, 0.0)
aMill.move(px4 - 0.05, py4)
aMill.mill_arc(px1,py1, 3.0)
aMill.mill_arc(px4 - 0.1, py4,  3.0)
aMill.move(px4 - 0.15, py4)
aMill.mill_arc(px1,py1, 3.0)
end

tx = 1.6
r = 3.0
tpe = py1
tpx = px1
while tx > 0.5
   aMill.retract()
   aMill.move(tpx,tpe)
   aMill.plung(-0.5)
   mill_arc(aMill, tx, py4, r)
   tx -= 0.05
   tpe -= 0.015
   #tpx += 0.001
   #r = r += 0.01
end



if false
aMill.move(px1,py1)
aMill.plung(-0.7)
aMill.move(px2, py2)
aMill.move(px3, py3)
aMill.move(px4, py4)
aMill.move(px5, py5)
aMill.move(px6, py6)

tx = px2 + 0.05 
ty = py2 - 0.1
tpy = py6
while(tx < px5)
  aMill.move(tx,ty)
  tx += 0.05
  tpy += 0.01
  aMill.move(tx,ty)
  aMill.move(px6,tpy)
  tpy -= 0.00
  tx += 0.05
end


end

#aMill.move(0.4, 0.5)
#aMill.mill_arc(0.4, 0.5, 1.5)
#aMill.mill_arc(1.6, 0.5, 1)
#aMill.move(1.6, 0.5)
#aMill.mill_arc(px2 - 0.08, pocket_y - 0.9, -1.5)
#aMill.move(px2 - 0.1,  pocket_y -0.9)
#Mill.move(px2, pocket_y)
aMill.retract

 # now mill out the center.
 

aMill.retract

aMill.home
aMill.job_finish

