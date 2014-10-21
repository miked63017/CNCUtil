require 'radial_fan'

module Pump_centrifuge_wheel_small

 #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  The smaller diameter wheels simply
  #  can not be implemented using standard
  #  pocketing because there is not room
  #  for the bit. This alternative approach
  #  is used whenever the wheel diameter
  #  is less than 9 times the bit diameter
  # 
  #  TODO:  Make a version of this that uses
  #    the standard arc pocket commands and
  #    to make 3 pockets and which then mills
  #    out the base depth over all the arc
  #    pockets and then makes the as many 
  #    spiral elements as will fit in the
  #    outer diameter ignoring where they
  #    intersect in the middle.  The reason for
  #    this approach is that it will maximize
  #    the number of slots at the periphery
  #    which should maximize the amount of air.
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_small_diameter_pump_wheel(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
     tSpeed            = mill.speed()
     tPlungSpeed       = mill.plung_speed()
     tCutDepthInc      = mill.cut_depth_inc()
     tCutInc           = mill.cut_inc     
     spoke_width       = wall_thick  
     spoke_dist        = (mill.bit_radius * 2)+ spoke_width * 1.2    
     bit_deg           = degrees_for_distance(air_entry_end_radius + mill.bit_radius, spoke_dist)
     bit_deg_wheel_diam= degrees_for_distance(wheel_radius, mill.bit_radius*1.9) 
     degrees_for_bit_radius = degrees_for_distance(wheel_radius, mill.bit_radius)
     no_slots          = (360.0 / bit_deg).to_i
     deg_per_slot      = 360.0 / no_slots
     spoke_angle       = deg_per_slot * 0.95
     main_slot_end_radius =  wheel_radius + mill.bit_radius
        
     
      print "(mill_small_diameter_pump_wheel material_type=", material_type, ")\n"      
      print "(wheel_diam=", wheel_diam,  " stock_z_len=", stock_z_len, ")\n"      
      print "(shaft_diam=", shaft_diam, ")\n" 
      print "(hub_diam=", hub_diam, ")\n"
      print "(air_entry_end_diam=", air_entry_end_diam, ")\n"
      print "(wall_thick = ", wall_thick, ")\n"
      print "(spoke_width=", spoke_width, ")\n" 
      print "(spoke_dist=", spoke_dist, ")\n"     
      print "(degrees for bit radius=", degrees_for_bit_radius, ")\n"
      print "(bit_deg=", bit_deg, ")\n"               
      print "(lhumb_diam=", hub_diam, ")\n"
      print "(no_slots = ", no_slots, ")\n"
      print "(deg_per_slot = ", deg_per_slot, ")\n"
      print "(spoke_angle  = ", spoke_angle, ")\n"
      print "(stock_z_len=", stock_z_len, ")\n"
      print "(blade_height=", blade_height, ")\n"  
      print "(bit_deg_wheel_diam=", bit_deg_wheel_diam, ")\n"
     
  if 1 == 99
     if (shaft_type == "D")
       # Have to reset cutout_diam to reflect
       # the smaller bit.      
       mill.retract()
       print "(L445 - shaft_diam = ", shaft_diam, ")\n"
       mill_DShaft(aMill, x = pCent_x,y=pCent_y, diam=shaft_diam, beg_z=0.0, end_z= drill_through_depth, adjust_for_bit_radius=true)
     else # round axel 
       aMill.retract()          
       aCircle = CNCShapeCircle.new(aMill)
       aCircle.beg_depth = 0 
       aCircle.mill_pocket(
         pCent_x, 
         pCent_y, 
         shaft_diam, 
         drill_through_depth ,  
         island_diam=0)          
     end
     mill.retract()
     
   
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          air_entry_end_diam, 
          0,
          blade_height, 
          false)          

     end # disable
          
     mill.retract()     
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          cutout_diam, 
          0,
          blade_height, 
          false)   
   
          
  
     
      num_air_entry = no_slots / 5
      if num_air_entry < 3
        num_air_entry = 3
      end 
     
      
    
      
      mill_radial_blades(mill, pCent_x, pCent_y, 
         shaft_diam + wall_thick + mill.bit_diam,   # beg_diam
         air_entry_end_diam - mill.bit_radius,   
         0, drill_through_depth, num_air_entry,spoke_dist)
         
     # center_air_entry_arc_pockets(
     #    pCent_x = pCent_x, 
     #    pCent_y = pCent_y, 
     #    outer_diam = air_entry_end_diam,  
     #    num_pockets = num_air_entry, 
     #    beg_z = 0,  
     #    end_z = drill_through_depth, 
     #    spike_width = wall_thick)     
     
     
     # Mill out as many slots as we can fit
     # in the current wheel.   Roughly
     # 30% of the center of each wheel will
     # be for air holes.
     curr_deg = 0     
     beg_radius = air_entry_end_radius + mill.bit_radius
     for slot_no in (1..no_slots)
       aMill.retract()
       end_angle = curr_deg + spoke_angle
      
       arc_to_radius(mill, pCent_x, pCent_y, 
         air_entry_end_radius + mill.bit_radius, curr_deg,  wheel_radius, 
         end_angle + bit_deg_wheel_diam, 
         0, 0 - blade_height)      
       
       arc_to_radius(mill, pCent_x, pCent_y, 
         air_entry_end_radius + mill.bit_radius,
         curr_deg, 
         wheel_radius,  
         end_angle + degrees_for_bit_radius, 
         0, 0 - blade_height)   
              
       curr_deg += deg_per_slot         
     end #for inner
     
   
     
     # Finish the coutout job with the last    
     # Cut most of the way through but with an cut
     # increments so we leave stock for a finish pass.              
          
     mill.retract()
     
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          cutout_diam, 
          blade_height,
          drill_through_depth, 
          false)   
     mill.set_speed(tSpeed)
     aMill.retract()         
     aMill.home()    
            
   
  end #meth  mill_small_pump_wheel

 
 

end #module

