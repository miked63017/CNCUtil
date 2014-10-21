# deep_first_circle.rb
#
# Test the ability of the bit to mill a much 
# deeper swath slower rather than doing only 
# surface milling.   The bit has all those deep
# teeth so perhaps we can use more of the useful
# cutting life of the bit.
# test_pump_housing_1.5_inch.rb
#
require 'cncMill'
require 'cncGeometry'
require 'cncShapeBase'
require 'cncShapeArc'
require 'cncShapeSpiral'
require 'cncShapeCircle'
require 'cncShapeRect'

# Mill a circle by first drilling to depth
# and then doing a face type cut of the entire
# surface all at once.  Upto the cutting area
# on the flute.   In this instance beg_diam is
# the same as island and will automatically be
# adjusted for bit_radius.   The end_diam will
# be for the outer radius of the circle pocket
# and will be automatically radius adusted in.
def mill_circle_df(mill, cx, cy, beg_diam, end_diam,  beg_depth, end_depth)
   
   # this circle also uses a total
   # spiral strategy for reaching the
   # diameter requested.  In that it
   # increases the radius by a very
   # small amount every step so that 
   # every once around the circle it 
   # increased by one cut_inc.  The
   # special case the outer cut
   # and the inner cut.
   degree_inc   = 1.0
   steps_per_circle = 360.0 / degree_inc
   beg_radius   = beg_diam / 2
   end_radius   = end_diam / 2
   beg_radius   += mill.bit_radius
   end_radius   -= mill.bit_radius
   if (beg_diam == 0)
     beg_radius = mill.bit_radius / 2.0
   end
   radius_dif   =  end_radius - beg_radius
   no_passes    =  (radius_dif / mill.cut_inc) 
     # makes my cut increment 50% smaller than normal.
     # when combined with slower speed should keep
     # bit out of trouble.
   loc_cut_inc  =  radius_dif / no_passes
   no_passes    =  radius_dif / loc_cut_inc # recalc to get an even integer of passes.
   print "(radius_dif=", radius_dif, "  no_passes=", no_passes,  " beg_radius=", beg_radius,  " end_radius=", end_radius, ")\n"
   if (beg_depth > 0)
     beg_depth = 0
   end 
   
   if (end_depth > 0)
     end_depth = 0 - end_depth
   end
  
   total_steps = (no_passes * steps_per_circle)
   radius_inc =  radius_dif / total_steps
   total_steps += steps_per_circle
   if (beg_diam != 0)
     total_steps += steps_per_circle
   end
   total_steps = total_steps.to_i()
   finish_radius = end_radius - 0.01
   tSpeed = mill.speed
   cut_depth = end_depth - beg_depth
   num_cut_layers = cut_depth / mill.cut_depth_inc
   use_speed = (tSpeed / num_cut_layers).abs * 2
   mill.set_speed(use_speed)
   print "(current speed=", tSpeed, "  cut_depth=", cut_depth, " num_cut_layers=", num_cut_layers, "  cut_depth_inc=", mill.cut_depth_inc, " use_speed=", use_speed, ")\n"
   
   print "(use_speed=", use_speed, "  cut_depth=", cut_depth, " total_steps=", total_steps, " radius_dif = ", radius_dif, ")\n"
   
   beg_cp = calc_point_from_angle(
                  cx,
                  cy, 
                  0, 
                  beg_radius)
                  
                  
   mill.move_fast(beg_cp.x, beg_cp.y)
   
   mill.drill(beg_cp.x,beg_cp.y, beg_depth, end_depth)
   
   mill.plung(end_depth)
  
   step_cnt = 0
   curr_deg = 0
   curr_radius = beg_radius
   print "(steps per circle=", steps_per_circle, ")\n"
   print "(Ready to enter while loop  total_steps=", total_steps, " step_cnt=", step_cnt, ")\n"
   tcnt = 5
   mill.retract(beg_depth)
   while(step_cnt <= total_steps) 
     #print "(step_cnt = ", step_cnt, ")\n"
     step_cnt += 1
     tcnt += 1
   
     cp = calc_point_from_angle(
                  cx,
                  cy, 
                  curr_deg, 
                  curr_radius)
         
       
          
    curr_deg += degree_inc
    curr_radius += radius_inc
    
    if (step_cnt <= steps_per_circle)
      # we are in the first circle around
      # so we are going to be plowing a full
      # bit diameter which means we have to 
      # go slower we normally would.     
      if (beg_diam != 0) && 
        curr_radius -= radius_inc
        #print "(keeping radius at ", curr_radius, " for first loop)\n"
        # This bit is kind of subtle in that
        # if there is an inner diameter specified
        # it will force the radius not to increment
        # for the first circle worth of steps.
      end
      if (tcnt > 5)  
        # On the first pass we move 5 degrees
        # and then plung the bit and then move
        # 5 more and plung again.  That allows
        # us to take more slices of without
        # overheating the bit on the first pass.
        mill.set_speed(use_speed / 2)      
        mill.move(cp.x,cp.y, end_depth)   
        mill.retract(beg_depth)
        tcnt = 0 
        mill.set_speed(use_speed * 6)
      end #if     
    elsif (curr_radius < finish_radius)
      if (tcnt > 10)  
        # On the the secondary passes we 
        # we move 10 degrees per pass 
        # to save time and since we 
        # are not taking a full cut
        mill.set_speed(use_speed)      
        mill.move(cp.x,cp.y, end_depth)   
        mill.retract(beg_depth)
        tcnt = 0 
        mill.set_speed(use_speed * 6)
      end #if  
    else
      # we are in the finish pass closer to 
      # 1/100 of an inch to finishing to we stay
      # down and move around for the finish cut.
      # and we go slower than normal
      mill.set_speed(use_speed)
      mill.plung(end_depth) # Do nothing most of the time
                            # but if first pass left it up
                            # by chance then we want to
                            # put it back down.
    end 
    
    if (curr_radius > end_radius)
          curr_radius = end_radius
          # This part is a little tricky because
          # if allows us to spiral out until we
          # get to the requested diameter and then
          # stay at that diameter until we run 
          # out of steps to do the finish
          # trim.
    end #if
    mill.move(cp.x,cp.y)
    
   end #while
   mill.set_speed(tSpeed)

end #meth





aMill = CNCMill.new
aMill.job_start()
aMill.retract_depth = 0.05
aMill.home()
aBit = aMill.current_bit

#bit2 = CNCBit.new(aMill, "config/bit/carbide-0.125X0.5X1.5-4flute.rb")

bit2 = CNCBit.new(aMill, "config/bit/carbide-0.250X0.75X2.5-6flute.rb")
aMill.curr_bit = bit2
bit2.recalc()

print "(calculated fspeed=", aMill.curr_bit.get_fspeed(), ")\n"
print "(bit diameter=",  aMill.bit_diam, ")\n"

aMill.pause("mount Carbide 1/4X0.5X2.5 6flute")

if (1 == 1)
   # deep circle 
   #  1.5" wide by 3/4" stock.
   
   stock_thick  = 0.5 #1.1
   stock_width =  1.5  #2.8
   remove_surface = 0.02
   stock_width = 1.5
  
   stock_center = stock_width / 2
   
   mill_circle_df(aMill, stock_center, stock_center, beg_diam=0.33, end_diam=stock_width * 0.8,  beg_depth=0.0, end_depth= stock_thick - 0.1)
     
   aMill.retract()
       
 
   
end #if




