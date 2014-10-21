# test_pump_housing_1.5_inch.rb
#
require 'cncMill'
require 'cncGeometry'
require 'cncShapeBase'
require 'cncShapeArc'
require 'cncShapeSpiral'
require 'cncShapeCircle'
require 'cncShapeRect'






aMill = CNCMill.new

aMill.job_start()
aMill.home
#aMill.retract_depth = 0.05
aMill.home
aBit = aMill.current_bit

#bit2 = CNCBit.new(aMill, "config/bit/carbide-0.125X0.5X1.5-4flute.rb")

bit2 = CNCBit.new(aMill, "config/bit/carbide-0.250X0.75X2.5-6flute.rb")
aMill.curr_bit = bit2
bit2.recalc()

print "(calculated fspeed=", aMill.curr_bit.get_fspeed(), ")\n"


# TODO:  Calculate speed and cutting increment we can use 
#  with Aluminum

aMill.pause("mount Carbide 1/4X0.5X2.5 6flute")

if (1 == 1)
   # Mill the Tesla pump housing for
   #  1.5" wide by 3/4" stock.
   
   stock_thick  = 0.75 #1.1
   stock_width =  1.5  #2.8
   remove_surface = 0.01
   stock_width = 1.5
  
   amount_lopside = stock_width * 0.20
   wall_thick         = 0.1
   floor_thick        = wall_thick * 2
   bottom_plate_thick = 0.125
   top_screw_thick = 0.125
   air_gap_at_bottom = 0.02
   bearing_inside_diam = 0.25
   bearing_outside_diam = 0.375
   bearing_thick  = 0.125
   lhub_diam      = bearing_outside_diam + (wall_thick * 3)
   shaft_diam    = 0.25
   min_wheel_clearance = 0.005
   cut_off_allowance = aMill.bit_diam
   
   
   # Bolts that go from the top cover
   # down through the housing
   mount_bolts_diam = 0.25
   mount_bolt_thread_diam = mount_bolts_diam - 0.05
   mount_bolt_length  = 0.64
   mount_bolt_head_thick = 0.1
   mount_bolt_head_diam  = 0.24
   bolt_space_from_edge = 0.2
   
   
   wheel_diam = stock_width - ((wall_thick * 0)  + (min_wheel_clearance * 2) +  (amount_lopside))
   wheel_radius = wheel_diam / 2.0
   print "(wheel_diam=", wheel_diam, ")\n"
   
   #mill out the entrance holes
   entrance_diam = 0.25
   #entrance_off_center_adj = (lhub_diam / 4)  + aMill.bit_radius
   entrance_off_center_adj = bearing_outside_diam / 2 +  aMill.bit_radius + wall_thick /2
   
   drill_through_depth = 0 - ( stock_thick + 0.05)
     
 
   max_left = cut_off_allowance
   lcx = max_left + wall_thick*2 + mount_bolts_diam + min_wheel_clearance + wheel_radius
   lcy = wall_thick + min_wheel_clearance + wheel_radius 
   
   print "(lcx=", lcx,  " lcy=", lcy, ")\n"
   
  
    aMill.retract()  
    
    cavity_diam = wheel_diam + (min_wheel_clearance)
    cr1 = cavity_diam / 2
    cr2 = (cavity_diam + amount_lopside) / 2
 
    curr_depth = 0
    
    vertical_space_used_non_wheel = floor_thick + bearing_thick + air_gap_at_bottom  + bottom_plate_thick + remove_surface
    
    main_wheel_thick = stock_thick - vertical_space_used_non_wheel 
    print "(main_wheel_thick =", main_wheel_thick, ")\n"

    max_right = lcx + cr2 + bolt_space_from_edge + wall_thick
    
    aCircle = CNCShapeCircle.new(aMill) # this circle re-used several times below
      
    
  
     # Mill off the surface to make sure we get a smooth
     # seal
     # Mill out exit area 
     # where the outlet hole
     # will be drilled
      aMill.retract()  
     aRect =  CNCShapeRect.new(aMill,
        0, 
        0 - aMill.bit_radius / 2, 
        max_right + aMill.bit_radius/2, 
        stock_width + aMill.bit_radius/2,
        0 - remove_surface)
        
     aRect.skip_finish_cut()
     aRect.do_mill()
     aMill.retract()
     curr_depth -= remove_surface
     
     aMill.retract()  
    #  Mill the exit hole
    cp = calc_point_from_angle(
                  lcx,
                  lcy, 
                  250, 
                  cr2 + (aMill.bit_radius / 8))

                  
     # Mill out exit area 
     # where the outlet hole
     # will be drilled
     end_y = bolt_space_from_edge + mount_bolt_thread_diam + wall_thick + aMill.bit_radius
     curr_y = cp.y 
     tSpeed = aMill.speed
     aMill.set_speed(tSpeed / 2.5)
     line_left = max_left + aMill.bit_radius + wall_thick
     line_depth = curr_depth - main_wheel_thick
     while (curr_y > end_y)
       beg_x = cp.x
       beg_y = cp.y + (amount_lopside * 0.2)
       end_x = beg_x
       end_y = curr_y
       aMill.move_fast(beg_x, beg_y)
       aMill.flat_line(beg_x, beg_y, curr_depth, 
       end_x, end_y,  line_depth)       
       curr_y -= aMill.cut_inc 
       aMill.set_speed(tSpeed)
     end
     aMill.set_speed(tSpeed)
     aMill.flat_line(cp.x,cp.y, curr_depth, 
       line_left, end_y,  line_depth)       
       curr_y -= aMill.cut_inc   
       
     aMill.retract(curr_depth)    
     
        
    mill_lopsided_circle(aMill, lcx, lcy, cavity_diam, cavity_diam + amount_lopside, -105.0, 245.0,curr_depth,curr_depth - main_wheel_thick)
   
    
   
      
    curr_depth  -= main_wheel_thick
    aMill.retract(curr_depth)
    aMill.move(lcx,lcy)
    #print "(Top of bearing slot=", curr_depth, ")\n"
     # This is the slot to hold the starting wheel.
     # this sheel also acts like the plug for the 
     # inlet air on that side.
     aMill.retract(curr_depth)
     
     #aMill.pause("Mill slot to accept thicker bottom wheel")
     aCircle.beg_depth = curr_depth
     aCircle.mill_pocket(lcx, lcy, 
       wheel_diam + min_wheel_clearance, 
       curr_depth - bottom_plate_thick,
       island_diam = 0)
    
     
    
     curr_depth -= bottom_plate_thick
     
     #aMill.pause("mill bearing holder")
     #aMill.retract(curr_depth)  
     aMill.retract() 
     aCircle.beg_depth = curr_depth 
     aCircle.mill_pocket(lcx, lcy, bearing_outside_diam, 
       curr_depth - bearing_thick ,  
       island_diam=0)   
     
     aMill.retract()
     #aMill.retract(curr_depth)
     #aMill.pause("drill center hole")
     aMill.drill(lcx, lcy, curr_depth, drill_through_depth) 
     aMill.retract() 
   
     #aMill.pause("mill out air space hole")
        
     
     retract_depth = curr_depth #+ bearing_thick  +air_gap_at_bottom

        
     aMill.retract(retract_depth) 
     tSpeed = aMill.speed
     aMill.set_speed(tSpeed/3) # slow down for full on cut
     mill_circle(aMill, lcx,lcy,
         wheel_diam + min_wheel_clearance,
         curr_depth,
         curr_depth -  bearing_thick,
         adjust_for_bit_radius = true)
     aMill.set_speed(tSpeed)
         
         
     #aMill.pause("mill out entrance hole  #1")    
     #curr_depth -= bearing_thick  
     aMill.retract(retract_depth) 
     aMill.drill(
       lcx - entrance_off_center_adj, 
       lcy, 
       curr_depth, drill_through_depth) 

     #aMill.pause("mill out entrance hole  #1")         
     aMill.retract(retract_depth) 
     aMill.drill(
       lcx + entrance_off_center_adj,
       lcy, 
       curr_depth,  drill_through_depth) 
       
     #aMill.pause("mill out entrance hole  #1")      
     aMill.retract(retract_depth) 
     aMill.drill(lcx, 
       lcy - entrance_off_center_adj, 
       curr_depth, drill_through_depth) 
       
     #aMill.pause("mill out entrance hole  #1")      
     aMill.retract(retract_depth) 
     aMill.drill(
       lcx, 
       lcy + entrance_off_center_adj, 
       curr_depth, drill_through_depth) 
    
       
     
     
     # --------------
     # -- ADD THE 4 Corner Mounting
     # -- holes
     # -------------         
     #aCircle.beg_depth = 0  
     curr_depth = 0 - remove_surface
     bolt_depth = drill_through_depth
     
     aMill.drill(
       max_left + bolt_space_from_edge,
       bolt_space_from_edge, 
       curr_depth, 
       bolt_depth) 
     
     aMill.retract()   
     aMill.drill(
       max_left + bolt_space_from_edge,
       stock_width - bolt_space_from_edge, 
       curr_depth, 
        bolt_depth) 
          
     aMill.retract()     
     aMill.drill(
      max_right - bolt_space_from_edge,
      stock_width -bolt_space_from_edge, 
      curr_depth, 
      bolt_depth) 
 
     aMill.retract()      
     aMill.drill(
       max_right - bolt_space_from_edge,
       bolt_space_from_edge, 
       curr_depth, 
       bolt_depth) 
       
  aMill.retract() 
  
  # chamfer the corners
  #aMill.flat_line(0.05
  
  
  # Assuming item is held on the left
  # cut off the right end first.      
  aMill.cut_off(
      bx = max_right + aMill.bit_radius,      
      by = 0 - 0.02,
      bz = 0 - remove_surface,
      ex = max_right + aMill.bit_radius,
      ey = stock_width + 0.02,
      ez = stock_thick + 0.01)    
  
  
   aMill.retract()          
   
   # now cut off the left end       
   aMill.cut_off(
      bx = 0 + aMill.bit_radius,      
      by = 0 - 0.02,
      bz = 0 - remove_surface,
      ex = 0 + aMill.bit_radius,
      ey = stock_width + 0.02,
      ez = stock_thick + 0.01)    
 
     
   aMill.retract()
       
end #if