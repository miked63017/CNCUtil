 #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  Mill a signle centrifuge pump wheel 
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_pump_wheel(pCent_x, pCent_y, pDiam,pShaft_diam, pCent_diam,  pstock_z_len,  pBase_thick,  pMaterial_type)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
      if (pDiam <= (mill.bit_diam * 100))  # normally *10
        return mill_small_diameter_pump_wheel(pCent_x, pCent_y, pDiam,pShaft_diam, pCent_diam,  pstock_z_len,  pBase_thick,  pMaterial_type)
      end
  
      print "(mill_pump_wheel pMaterial_type=", pMaterial_type, ")\n"
      print "(pDiam=", pDiam,  " pstock_z_len=", pstock_z_len, ")\n"
 
      if pMaterial_type == "acrylic" and pstock_z_len == 0.25
         pstock_z_len = 0.018
      end  
                      
     mill.curr_bit.recalc()  
     mill.curr_bit.adjust_speeds_by_material_type(pMaterial_type)
     tSpeed = mill.speed()
     tPlungSpeed = mill.plung_speed()
     tCutDepthInc = mill.cut_depth_inc()
     tCutInc  = mill.cut_inc
     stock_z_len = pstock_z_len
     lout_diam = pDiam
     lhub_diam  = pShaft_diam + wall_thick
     num_outer_slots = (pDiam / mill.bit_diam).to_i
     if (num_outer_slots < 3)
       num_outer_slots = 3
     end
     entrance_area_diam = pDiam * 0.5
     entrance_area_radius = entrance_area_diam / 2.0
     
     num_inner_slots = ((entrance_area_diam / mill.bit_diam) * 0.9).to_i     
     if (num_inner_slots < 3)
       num_inner_slots = 3
     end
     
     spoke_angle = 45
     spoke_width = 0.1
     
     lblade_depth    = pstock_z_len - (pBase_thick + air_gap_at_bottom)
     lbase_thick     = pstock_z_len - lblade_depth
     blade_height    = pstock_z_len - pBase_thick
   
     if (entrance_area_diam < lhub_diam + mill.bit_diam)
       lhub_diam = lout_diam
     end
     lhub_radius = lhub_diam / 2.0
     
     cutout_diam  = pDiam + (aMill.bit_radius * 2)
     outline_diam = cutout_diam + mill.cut_inc
        
     print "(entrance_area_diam=", entrance_area_diam, ")\n"
     print "(lhumb_diam=", lhub_diam, ")\n"
     
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
     entrance_area_radius + (mill.bit_radius/2.0), num_inner_slots, 0, pstock_z_len, spoke_angle/2.0, spoke_width)
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
     mill.curr_bit.adjust_speeds_by_material_type(pMaterial_type)
     # Have to reset cutout_diam to reflect
     # the smaller bit.
     cutout_diam  = pDiam + (aMill.bit_radius * 2)
     
     mill.retract()
     mill_DShaft(aMill, x = pCent_x,y=pCent_y, diam=pShaft_diam, beg_z=0.0, end_z= pstock_z_len, adjust_for_bit_radius=true)
     
     

     
     # Finish the coutout job with the last
     mill.set_speed(tSpeed * 0.8)
     mill.retract()
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          cutout_diam, 
          0,
          0 - (pstock_z_len), 
          false)   
      mill.set_speed(tSpeed)
     aMill.retract()
     mill.curr_bit = old_bit
     old_bit.recalc()
     aMill.retract()
     aMill.home()    
            
   
  end #meth  mill_pump_wheel

