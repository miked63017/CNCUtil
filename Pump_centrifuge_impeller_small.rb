require 'radial_fan'

module Pump_centrifuge_impeller_small

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
  #
  #  TODO: Make a version of this that uses a standard
  #  arch pocket to mill the pocket at the bottom of
  #  each fin. I think that one will be less likely
  #  to discintigate under extreem loads. Call it
  #  strong 
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_small_diameter_pump_wheel(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
   
      
     spoke_width       = wall_thick  
     spoke_dist        = (mill.bit_radius * 2)+ spoke_width * 1.2    
     bit_deg           = degrees_for_distance(air_entry_end_radius + mill.bit_radius, spoke_dist)
     bit_deg_wheel_diam= degrees_for_distance(wheel_radius, mill.bit_radius*1.9) 
     degrees_for_bit_radius = degrees_for_distance(wheel_radius, mill.bit_radius)
     no_slots          = (360.0 / bit_deg).to_i
     deg_per_slot      = 360.0 / no_slots
     spoke_angle       = deg_per_slot * 0.95
     main_slot_end_radius =  wheel_radius + mill.bit_diam
        
     
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
     # TODO: Make this smart enough to 
     #  save the bit file name from the
     #  original bit that was in place
     #  when we entered and restore it
     #  rather than the 1/4" diameter bit
     #  by default.
     
     old_bit = mill.curr_bit     
     
     # TODO: Consider moving this bit selection
     #  logic to  mill_impeller_axel where other
     #  types of wheels can take advantage of it
     if (shaft_diam < mill.bit_diam)
       if (shaft_diam < 0.125)
         mill.load_bit("config/bit/carbide-0.0625X0.25X1.5-4flute.rb", "insert 1/16 inch bit and set to be exactly 1.0 inches above surface using spacer block", 1.02, material_type)    
       elsif (shaft_diam < 0.250)
         mill.load_bit("carbide-0.125X0.5X1.5-4flute.rb", "insert 1/8 inch bit 0.5 inch flute", 1.02, material_type)             
       else
         mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "insert 1/4 inch 2 flute 0.55 bit exactly 2.0 above", 2.02, material_type)             
       end
       mill.plung(0)
       mill.pause("Final adjust bit for 0.0 Z")             
       mill_impeller_axel(pCent_x, pCent_y,0,drill_through_depth)
         
       # Reload our normal bit
       if (mill.bit_diam != 0.250)        
         mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "insert 1/4 inch 2 flute 0.55 bit exactly 2.0 above", 2.02, material_type)               
         mill.plung(0.0)
         mill.pause("Final adjust bit for 0 Z")             
       end       
     else     
      # exisiting bit was OK for axel shaft
           
      mill_impeller_axel(pCent_x, pCent_y,0,drill_through_depth)
     end
     
     #mill.curr_bit = old_bit
     #mill.curr_bit.bit2.recalc()           
      
     #mill.load_bit("config/bit/carbide-0.0625X0.25X1.5-4flute.rb", "insert 1/16 inch bit and set to be exactly 1.0 inches above surface using spacer block", 1.0, material_type)    

   
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          air_entry_end_diam, 
          0,
          blade_height * 0.9, 
          false)          

     
          
     mill.retract()     
        
     # We have to spiral down early
     # because otherwise it seems to 
     # chip the end of the fins when
     # milling brittle materials.     
     spiral_down_circle(
         mill = aMill, 
         x  =  pCent_x,
         y  =  pCent_y, 
         diam = cutout_diam, 
         beg_z=0, 
         end_z=blade_height, 
         adjust_for_bit_radius=false, 
         outside=true, 
         auto_speed_adjust=false)           
   
          
   
     
      num_air_entry = 5      
      air_entry_beg_diam = shaft_diam + wall_thick + (mill.bit_diam * 1.5)           
      if (mill.bit_diam < 0.25)
        air_entry_beg_diam += 0.25
      end
      
      mill_radial_blades(mill, pCent_x, pCent_y, 
         air_entry_beg_diam,   # beg_diam
         air_entry_end_diam,   
         0, drill_through_depth, num_air_entry,spoke_dist)
                    
     
     # Mill out as many slots as we can fit
     # in the current wheel.   Roughly
     # 30% of the center of each wheel will
     # be for air holes.
     curr_deg = 0     
     beg_radius = air_entry_end_radius + mill.bit_radius
     
     deg_for_adj2 = degrees_for_bit_radius * 1.9
     if (deg_for_adj2 > spoke_angle * 0.75)
       deg_for_adj2 = spoke_angle * 0.75
     end
     
     for slot_no in (1..no_slots)
       aMill.retract()
       end_angle = curr_deg + spoke_angle
      
       arc_to_radius(mill, pCent_x, pCent_y, 
         air_entry_end_radius + mill.bit_radius, curr_deg,  wheel_radius + mill.bit_radius, 
         end_angle + bit_deg_wheel_diam, 
         0, 0 - blade_height)      
       
       arc_to_radius(mill, pCent_x, pCent_y, 
         air_entry_end_radius + mill.bit_radius,
         curr_deg, 
         wheel_radius + mill.bit_radius,  
         end_angle + bit_deg_wheel_diam + deg_for_adj2, 
         0, 0 - blade_height)   
              
       curr_deg += deg_per_slot         
     end #for inner
     
   
     
     # Finish the coutout job with the last    
     # Cut most of the way through but with an cut
     # increments so we leave stock for a finish pass.              
          
     mill.retract()
          

    
               
     # TODO:  Change this to the call for
     #  cutout wheel which leaves the 4 tabs 
     #  to late snipping. 
     #spiral_down_circle(
     #    mill = aMill, 
     #    x  =  pCent_x,
     #    y  =  pCent_y, 
     #    diam = cutout_diam, 
     #    beg_z=blade_height, 
     #    end_z=drill_through_depth * 0.97, 
     #    adjust_for_bit_radius=true, 
     #    outside=true, 
     #    auto_speed_adjust=false)      
  
     cut_out_circ_nub(pCent_x, pCent_y, pDiam=wheel_diam, pBegZ=blade_height, pEndZ=drill_through_depth)
                       
     
     #mill.set_speed(tSpeed)
     aMill.retract()         
     aMill.home()    
      
   
  end #meth  mill_small_pump_wheel

 
 

end #module

