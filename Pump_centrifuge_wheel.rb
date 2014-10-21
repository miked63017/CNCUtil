module Pump_centrifuge_wheel


   
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  Mill a signle centrifuge pump wheel 
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_pump_wheel(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    
      print "(mill_pump_wheel material_type=", material_type, ")\n"
      print "(wheel_diam=", wheel_diam,  " stock_z_len=", stock_z_len, ")\n"
 
      if material_type == "acrylic" and stock_z_len == 0.25
         stock_z_len = 0.018
      end  
                      
     mill.curr_bit.recalc()  
     mill.curr_bit.adjust_speeds_by_material_type(material_type)
     tSpeed = mill.speed()
     tPlungSpeed = mill.plung_speed()
     tCutDepthInc = mill.cut_depth_inc()
     tCutInc  = mill.cut_inc
     stock_z_len = stock_z_len
     lout_diam = wheel_diam
     hub_diam  = shaft_diam + wall_thick
     num_outer_slots = (wheel_diam / mill.bit_diam).to_i
     if (num_outer_slots < 3)
       num_outer_slots = 3
     end
     entrance_area_diam = wheel_diam * 0.5
     entrance_area_radius = entrance_area_diam / 2.0
     
     num_inner_slots = ((entrance_area_diam / mill.bit_diam) * 0.9).to_i     
     if (num_inner_slots < 3)
       num_inner_slots = 3
     end
     
     spoke_angle = 45
     spoke_width = 0.1
     
     lblade_depth    = stock_z_len - (pBase_thick + air_gap_at_bottom)
     lbase_thick     = stock_z_len - lblade_depth
     blade_height    = stock_z_len - pBase_thick
   
     if (entrance_area_diam < hub_diam + mill.bit_diam)
       hub_diam = lout_diam
     end
     lhub_radius = hub_diam / 2.0
     
    
     outline_diam = cutout_diam + mill.cut_inc
        
     print "(entrance_area_diam=", entrance_area_diam, ")\n"
     print "(lhumb_diam=", hub_diam, ")\n"
     
     aMill.retract()     
      
    
   
    # Outline of the wheel size to 
    # more readily show how things
    # will look when finished.
    mill.retract()
    mill.set_speed(tSpeed * 0.8)
    spiral_down_circle(aMill, pCent_x, pCent_y, 
          outline_diam, 
          0,
          0 - (remove_surface_amt * 2), 
          false)
    
          
     # mill out transition zone
     # between inner and outer blade
     # patterns.       
     aMill.retract()
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          entrance_area_diam, 
          0,
          0 - (blade_height), 
          false)
     mill.set_speed(tSpeed)
     aMill.retract() 
 
       
     # Mill out the inner slots for the blade
     # air entrance
     mill.set_speed(tSpeed*0.9)  
     mill.set_cut_depth_inc(tCutDepthInc * 0.5)            
     mill.retract()                  
     mill_out_air_entrance(mill, pCent_x, pCent_y, lhub_radius + mill.bit_radius, 
     entrance_area_radius + (mill.bit_radius/2.0), num_inner_slots, 0, stock_z_len, spoke_angle/2.0, spoke_width)
     mill.set_speed(tSpeed)
     mill.set_plung_speed(tPlungSpeed)       
           
     
     
     # Mill out the outer slots for the blade
     mill.retract() 
     mill.set_speed(tSpeed*0.8)
     mill.set_cut_depth_inc(tCutDepthInc * 0.7)
     mill_out_air_entrance(mill, pCent_x, pCent_y, entrance_area_radius - (mill.bit_radius/2.0),
       (outline_diam + (mill.bit_radius)) / 2.0,
        num_outer_slots, 0, blade_height, spoke_angle, spoke_width)     
     mill.set_cut_depth_inc(tCutDepthInc) 
 
          
  
     ## Cut most of the way through
     ## but with an cut increments so we
     ## leave stock for a finish pass.   
     mill.retract()
     mill.set_speed(tSpeed * 0.7)
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          outline_diam, 
          0,
          0 - (blade_height), 
          false)    
     mill.set_speed(tSpeed)   
                   
     aMill.retract(0.5)      
     aMill.pause("Please place 3/16 bit and adjust for 0.75on Z to surface")
     bit2 = CNCBit.new(aMill, "config/bit/carbide-0.1875X0.50X1.5-2flute.rb")

  
     #bit2 = CNCBit.new(aMill, "config/bit/carbide-0.250X0.75X2.5-6flute.rb")
     old_bit = aMill.curr_bit
     aMill.curr_bit = bit2
     bit2.recalc()
     mill.curr_bit.adjust_speeds_by_material_type(material_type)
     
     
     mill.retract()
     mill_DShaft(aMill, x = pCent_x,y=pCent_y, diam=shaft_diam, beg_z=0.0, end_z= stock_z_len, adjust_for_bit_radius=true)
     
     

     
     # Finish the coutout job with the last
     mill.set_speed(tSpeed * 0.8)
     mill.retract()
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          cutout_diam, 
          0,
          0 - (stock_z_len), 
          false)   
      mill.set_speed(tSpeed)
     aMill.retract()
     mill.curr_bit = old_bit
     old_bit.recalc()
     aMill.retract()
     aMill.home()    
            
   
  end #meth  mill_pump_wheel


  
   
  #  Mill a simple pump wheel lid which 
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_pump_wheel_lid(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
     print "(mill_pump_wheel_lid)\n"  
     mill.retract()
     
     print "(L995 - shaft_diam = ", shaft_diam, ")\n"
    
     if (shaft_type == "D")
       mill_DDShaft(aMill, 
          x = pCent_x,
          y = pCent_y, 
          diam = shaft_diam, 
          beg_z = 0.0, 
          end_z = drill_through_depth, 
          adjust_for_bit_radius=true)
     else # round axel 
        aMill.retract()
        aCircle = CNCShapeCircle.new(aMill)                 
        aCircle.beg_depth = 0         
        aCircle.mill_pocket(pCent_x, pCent_y, shaft_diam, 
          drill_through_depth ,  
          island_diam = 0)          
     end
       
     
          
     # Coutout job with the last    
     mill.retract()
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          cutout_diam, 
          0,
          drill_through_depth * 0.97, 
          false)   
          
     aMill.retract()
     aMill.home()    
            
   
   end #meth  mill_pump_wheel_lid
   
   
   
  
 
   

end # end Module