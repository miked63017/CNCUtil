#  drill_micro_bubble_diffuser.rb
#  
#   Drill a pattern of holes in a plate to be used
#   for the micro bubble diffuser in the distillation
#   system. 
# 
require 'cncMill'




  



#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.


aMill  =  CNCMill.new
aMill.job_start()

option = 0

if (option == 0)
  # mill the grid of small holes on bottom of small
  # curved diffuser.  this is used to drill 3 holes
  # wide but at an angle. 
  pwidth     = 7
  plen       = 0.3
  mill_depth = -0.20
  x_inc      = 0.1
  y_inc      = 0.1
  aMill.load_bit("config/bit/carbide-0.0625X0.25X1.5-4flute.rb", "Load 1/16 inch bit", 0.5, "acrylic")    
  aMill.home()
  curr_x = 0
  curr_y = 0
  xic = 0
  yic = 0
  
  while (curr_x <= pwidth)
      print "\n(curr_y= ", curr_y, " curr_x=", curr_x, " )\n"
      aMill.retract()
      aMill.move_fast(curr_x, curr_y)
      aMill.drill_x(cxi = curr_x,
        cyi = 0 - y_inc,
        beg_depth = 0, 
        end_depth = mill_depth) 
      
     aMill.drill_x(cxi = curr_x + x_inc,
        cyi = 0,
        beg_depth = 0, 
        end_depth = mill_depth) 
        
     aMill.drill_x(cxi = curr_x + x_inc * 2,
        cyi = 0 + y_inc,
        beg_depth = 0, 
        end_depth = mill_depth) 
      curr_x += x_inc
  
      curr_x += x_inc
  
    aMill.retract(3) # spread the grease around on the axis
  
  end # while x
  
end #if option == 1

if (option == 1)
  # mill the grid of small holes. 
  # this verison has been tested with bits as small
  # as 0.028 but I didn't bother creating a new bit
  # definition.
  pwidth     = 8.5
  plen       = 6.0
  mill_depth = -0.15
  x_inc      = 0.4
  y_inc      = 0.5
  aMill.load_bit("config/bit/carbide-0.0625X0.25X1.5-4flute.rb", "Load 1/16 inch bit", 0.5, "acrylic")    
  aMill.home()
  curr_x = 0
  curr_y = 0
  xic = 0
  yic = 0
  while (curr_y <= plen)
  
    while (curr_x <= pwidth)
      print "\n(curr_y= ", curr_y, " curr_x=", curr_x, " )\n"
      aMill.retract()
      aMill.move_fast(curr_x, curr_y)
      aMill.drill_x(cxi = curr_x,
        cyi = curr_y,
        beg_depth = 0, 
        end_depth = mill_depth) 
      curr_x += x_inc
      #xic += 1
      #if (xic > 2) 
      #  aMill.retract(2)
      #  curr_x += x_inc * 2
      #  xic = 0
      #end
    end # while y
    curr_y += y_inc
    curr_x = 0
    #yic += 1
    #if (yic > 10)
    #  curr_y += y_inc * 2
    #  yic = 0
    #end
    aMill.retract(3) # spread the grease around on the axis
  
  end # while x
  
end #if option == 1

if (option == 2)
  # Mill out top side of diffuser
  aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch bit", 0.5, "acrylic")    
  x_len = 1.3
  y_len = 1.0
  z_len = -0.16

  # Mill out the rectangular 
  # hole to allow allow the inlet
  # air to move into the diffuser.
  x_off = 1
  y_off = 1
  aMill.retract()
  aMill.move_fast(x_off, y_off)  
  aMill.mill_rect(lx = x_off,
    ly = y_off, 
    mx = x_off + x_len, 
    my = y_off + y_len, 
    depth = z_len, 
    adjust_for_bit_radius=true)        
  aMill.home()  
end

if (option == 3)
  # Mill out the holes for the top lid of evaporation
  # chamber.
  aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch bit", 0.5, "acrylic")    
  x_len = 1.3
  y_len = 1.0
  z_len = -0.16

  # Mill out the rectangular 
  # hole to allow allow the inlet
  # air to move into the diffuser.
  x_off = 1
  y_off = 1
  aMill.retract()
  aMill.move_fast(x_off, y_off)  
  aMill.mill_rect(lx = x_off,
    ly = y_off, 
    mx = x_off + x_len, 
    my = y_off + y_len, 
    depth = z_len, 
    adjust_for_bit_radius=true)
    
  # this is the Exit hole 
  # for the air pulled out
  # by the air pump  
  aMill.retract()
  x_off = 6
  y_off = 4
  aMill.move_fast(x_off, y_off)  
  aMill.mill_rect(lx = x_off,
    ly = y_off, 
    mx = x_off + x_len, 
    my = y_off + y_len, 
    depth = z_len, 
    adjust_for_bit_radius=true)
    
  aMill.home()  
end



aMill.retract
aMill.home()
aMill.job_finish()
 