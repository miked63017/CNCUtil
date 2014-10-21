# Letter / Vector Number Rendor
#  Designed to produce a custom matrix based
#  letter and number for milling that can be
#  scaled and sized as needed for milling operations
#
#  The ultimate intention is to have a specific matrix
#  shaping that I can easily use to computer recognition
#  similar to OCR-A but with better support for 
#  parralax distortion when the imaging sensor is held at an 
#  In ideal scenario we can allow scanner based reading 
#  from camera built into a ipaq and use local algorithms 
#  to read the numbers rather than requiring a bard code
#  scanner. 
#
#
#  This is intended to allow milling on a 3D surface which
#  means the letters have to curve around the 3D face.


#  Each letter is composed of a 8X8 matrix.  We can use
#  the milling machine to draw lines and curves but we
#  ultimately will be depending on the presence of 
#  information in each cell of the matrix in order to 
#  do future recognition.
# 
#  TODO:  Scale should be specified in characters per inch.
#    rather than an arbitrary number.
#
#  TODO:  Set retract depth to something less than
#    normal to save the plung time.
#
#  TODO:  Need to allow a slant up or slant down.
#  TODO:  Need to allow a curve that we would follow 
#         around the bottle.
#
require 'cncMill'
require 'cncGeometry'
require 'cncShapeBase'

# Need to allow a two digit move which will assume
# last postion as starting point
# Segments may have either for pieces in which case
# they are two fully specified end points.  Or they
# may have two segments in which case they will use
# the ending off the prior segement as their begining
# and the two new coordinates is the new end point.
# 

# TODO:  Move the font defenition to a separate file
#  and pass the font into the text rendering The font
#  should allow a base size to be defined rather than
#  assuming a 8X8 matrix.
#
# TODO:  The Font should support concept of a stroke
#   rather than a segment which is the same thing but
#   the stroke is more generic.
#
CharM= {}
CharM['A'] = [[0,0,4,0],[0,8],[2,3,6,3]]
CharM['0'] = [[0,0],[7,0],[7,7],[0,7],[0,0],[3.9,3.9,4.1,4.1]]
CharM['1'] = [[3,0],[6,0],[4,0],[4,8],[3,7]]
CharM['2'] = [[0,8,8,8],[8,4],[0,4],[0,0],[8,0]]
CharM['3'] = [[0,0],[8,0],[8,4],[2,4],[8,4],[8,8],[0,8]]
CharM['4'] = [[0,8],[0,4],[8,4],[6,4],[6,8],[6,0]]
CharM['5'] = [[8,8,0,8],[0,4],[8,4],[8,0], [0,0],[0,1]]
CharM['6'] = [[]]
CharM['7'] = [[]]
CharM['8'] = [[]]
CharM['9'] = [[]]
CharM['-'] = [[2,4,6,4],[6,5],[2,5],[2,4]]
CharM['/'] = [[1,1,7,7]]
CharM['|'] = [[4,0,4,8],[4,8,5,8],[5,8,5,0]]



# mill the specified character at the beg_x, beg_y
# rotated by angle sized by scale.   Assume that 
# all letters have 0,0 at bottom left and that they
# are scaled for drawing at 8,8.   If angle is specified
# We calculate the center of the 8,8 grid and rotate
# the letter around that point.   If Scale is specified
# then any number we receive is multiplied by scale before
# adding to beg_x, beg_y for final move_to.
#
def mill_char(mill, aChar, beg_x, beg_y, angle=0, scale=0.01, depth = -0.05, mirror=false)
   scale = scale + 0.0
   print "(scale=", scale, ")\n"
   print "(mirror=", mirror,")\n"
   #print "( angle=", angle, " scale=", scale, ")\n"
   mill.retract()
   if scale == 1
     scale = scale / 100.0
   end 
   #print "(mill char  mill=", mill,  " aChar= ", aChar, " beg_x=", beg_x, " beg_y=", beg_y,  ")\n"
   
   end_x = beg_x + (8.0 * scale)
   end_y = beg_y + (8.0 * scale)
   mid_x = (beg_x + end_x) / 2.0
   mid_y = (beg_y + end_y) / 2.0
   
   
   if CharM.has_key?(aChar)   
     acc = CharM[aChar]
     last_seg = nil
     lbx = nil
     lby = nil
     lex = nil
     ley = nil
     #print "(aChar=", aChar, " acc=", acc, ")\n"
     cnt = 0
     for aSeg in acc
       cnt += 1
       #print "(a seg=", aSeg, ")\n"
       # TODO:  It should be possible to label a Arc with
       #  to end points and a third end point to define
       #  the circumference.   This would take the form 
       #  of the first parameter of the segment taking
       #  a single character such as 'A' for arc. 
       # TODO: Consider switching from this simple text
       #  type representation to a object representation
       #  such as   line(0,0,4,4) which would in initialize
       #  a line object.  More work but more extensible 
       #  and more correct.
       
       if (aSeg.length == 4)
         # fully specified segment
         if (mirror == true)
           obx = bx = ((8 - aSeg[0]) * scale) 
           oex = ex = ((8 - aSeg[2]) * scale) 
         else
           obx = bx = (aSeg[0] * scale) 
           oex = ex = (aSeg[2] * scale)          
         end #if
         
         oby = by = (aSeg[1] * scale) 
         oey = ey = (aSeg[3] * scale) 
       else
         # chaining from one segment to the next
         if (lex == nil) or (ley == nil)
           # First element so we are 
           # actually starting at this
           # location
           if (mirror == true)
             bx = obx = (8 - aSeg[0]) * scale
             by = oby = aSeg[1] * scale           
           else
             bx = obx = aSeg[0] * scale
             by = oby = aSeg[1] * scale
           end
           lex = oex = ex = bx
           ley = oey = ey = oby
         else
           obx = bx = lex
           oby = by = ley
         end #if   
         if (mirror == true)       
           oex = ex = (8 - aSeg[0]) * scale
         else
           oex = ex = aSeg[0] * scale
         end #if
         oey = ey = aSeg[1] * scale
       end #if
       
       
      
      
       
       
       if angle == -9999999
         #print "begin angle calc)\n"
         bp = calc_point_from_angle(mid_x, mid_y, angle, bx / 2)
         bx = bp.x
         by = bp.y
         
         ep = calc_point_from_angle(mid_x, mid_y, angle, ex / 2)
         ex = ep.x
         ey = ep.y
         
       end #if angle specified
     
       bx += beg_x
       by += beg_y
       ex += beg_x
       ey += beg_y
       
     
       if (obx != lex) || (oby != ley)
         mill.retract()
       end #if
       #print "(a seg=", aSeg, ")\n"
       #print "move to bx=", bx, " by=", by, " ex=", ex,  " ey = ", ey, ")\n"
     
       if (cnt == 1)
         mill.move_fast(bx,by)
       else
         mill.move(bx,by)
       end #if
       mill.plung(depth)
       mill.move(ex,ey)
     
     
       lbx = obx
       lby = oby
       lex = oex
       ley = oey             
       
     end # for
     mill.retract()
     
     
   end # found character
 end #meth
     

def mill_text(mill, aStr, beg_x, beg_y, angle=0, cpi=10, depth=nil, mirror=false)
  cpi = cpi + 0.0
  char_size = 1 / cpi
  scale = (char_size * 0.9) / 10.0  
  print "(char_size=", char_size, "scale=", scale, ")\n"
  curr_x = beg_x
  curr_y = beg_y
  cc     = 0
  ccl = aStr.length
 
  while cc < ccl
    mill.retract()
    aChar = aStr[cc].chr
    radius = cc * char_size
    cangle = angle + 90.0
    #print "(char_angle=", angle, " angle = ", angle, ")\n"
    bp = calc_point_from_angle(beg_x, beg_y, angle, radius)
    mill_char(mill, aChar, bp.x, bp.y, cangle, scale, depth, mirror=mirror)
    cc += 1
  end #for


end # meth



aMill = CNCMill.new
aMill.job_start()
aMill.home
aMill.set_speed(0.1)
aMill.plung_speed = 0.1
aMill.retract_depth = 0.02


print "aBit.cut_depth_max=", aBit.cut_depth_max


#mill_char(aMill, '0', 0.0, 0.0, angle=31.0,scale=1, depth=-0.05)
mill_text(aMill, "5012-03-21-31/40", 0, 0, angle=90, cpi=8, depth=-0.015, mirror=false)
#mill_text(aMill, "2", 0, 0, angle=90, scale=1, depth=-0.35)

aMill.job_finish()

