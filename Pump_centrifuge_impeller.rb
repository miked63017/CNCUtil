module Pump_centrifuge_impeller

  #  TODO:  Save the original bit file name
  #   so that we can restore that bit rather
  #   than reloading the 1/4" bit arbitraily
  #
  #  TODO: Consider moving this bit selection
  #  logic to  mill_impeller_axel where other
  #  types of wheels can take advantage of it
  #   
  #  # TODO: Make this smart enough to 
     #  save the bit file name from the
     #  original bit that was in place
     #  when we entered and restore it
     #  rather than the 1/4" diameter bit
     #  by default.
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_axel_with_approapriate_sized_bit(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
     old_bit = mill.curr_bit             
     if (shaft_diam >= mill.bit_diam)
        # exisiting bit was OK for axel shaft
        mill_impeller_axel(pCent_x, pCent_y,false, 0,drill_through_depth)
     else     
       # Current bit is too large for the
       # axel hole
       if (shaft_diam < 0.125)
         mill.load_bit("config/bit/carbide-0.0625X0.25X1.5-4flute.rb", "insert 1/16 inch bit and set to be exactly 0.75 inches above surface using spacer block", 0.76, material_type)    
       elsif (shaft_diam < 0.250)
         mill.load_bit("carbide-0.125X0.5X1.5-4flute.rb", "insert 1/8 inch bit 0.5 inch flute", 1.02, material_type)             
       else
         mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "insert 1/4 inch 2 flute 0.55 bit exactly 1.5 above", 1.51, material_type)             
       end
       mill.plung(0.01)
       mill.pause("Final adjust axel bit for 0.0 Z")
       
       mill_impeller_axel(pCent_x, pCent_y,false, 0, drill_through_depth)
         
       # Reload our normal bit
       if (mill.bit_diam != 0.250)                  
         mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "insert 1/4 inch 2 flute 0.55 bit exactly 2.0 above", 2.02, material_type)               
         mill.plung(0.02)
         mill.pause("Final adjust bit for 0.0 Z")         
       end                   
     end
     mill.retract()
     mill.move(pCent_x, pCent_y)
   end #method
   
   
 #  #  #  #  #  #  #  #  #  #  #  #  #  #
 # Mill the impeller axel in the actual wheel
 # either as a circle or as a double flattened
 # D.
 #  #  #  #  #  #  #  #  #  #  #  #  #  #
 def mill_impeller_axel(pCent_x, pCent_y, mirrored=false, pBegZ=0, pEndZ=nil)
 #  #  #  #  #  #  #  #  #  #  #  #  #  #
     if pEndZ == nil
       pEndZ = drill_through_depth
     end
     pEndZ = 0 - pEndZ.abs
   
     print "(mill_impeller_axel pCent_x=", pCent_x, " pCent_y=", pCent_y, " pBegZ=", pBegZ, " pEndZ=", pEndZ, ")\n"
     print "(shaft_diam=", shaft_diam, ")\n"
     
     # ensure that we do not exceed the bit flute  length
     # for the 1/16 inch bit.
     if (mill.curr_bit.max_mill_depth.abs < pEndZ.abs)
       pEndZ = 0 - mill.curr_bit.max_mill_depth.abs
     end
     
     
     if  (mill.curr_bit.flute_smaller_than_shaft == true) and (mill.curr_bit.flute_len.abs <  pEndZ.abs)
         # If I have a bit with a flute that is smaller
         # than the shaft I can not mill any deeper than
         # the flute so automatically adjust the max
         # depth to match the flute
         print "(bit flute is not long enough for axel hole and shaft is larger than flute so setting hole size to flute_len)\n"
         pEndZ = 0 - mill.curr_bit.flute_len.abs
     end
       
       
     if (shaft_type == "D")
       # Have to reset cutout_diam to reflect
       # the smaller bit.      
       mill.retract()
       print "(L445 - shaft_diam = ", shaft_diam, ")\n"
       mill_DDShaft(mill, x = pCent_x,y=pCent_y, diam=shaft_diam, beg_z=pBegZ, end_z= pEndZ, adjust_for_bit_radius=true, mirrored=mirrored)
     else # round axel 
       if mirrored == true
         tcy = vmirror(pCent_y)
       else
         tcy = pCent_y
       end

       mill.retract()          
       aCircle = CNCShapeCircle.new(mill)       
       print "(ZZZZZZZZZZZZ mill_impeller_axel pBegZ=", pBegZ, " pEndZ=", pEndZ,")\n"
       aCircle.beg_depth = pBegZ 
       aCircle.mill_pocket(
         pCent_x, 
         tcy, 
         shaft_diam, 
         pEndZ ,  
         island_diam=0)
              
                   
     end # axel choice
     mill.retract()
  end # method
     
  
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_slots(pCent_x, pCent_y, slot_beg,  slot_end, pBeg_z, pEnd_z, spoke_dist, is_inner_slot, mill_circle_first=true)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    print "\n(pump_centrifuge_impeller.mill_slots)\n"
    print "(pCent_x=", pCent_x, " pCent_y=", pCent_y, ")\n"
    print "(slot_beg=", slot_beg, " slot_end=", slot_end, ")\n"
    print "(pBeg_z=", pBeg_z, " pEnd_z=", pEnd_z, ")\n"
    print "(spoke_dist=", spoke_dist, "  is_inner_slot=", is_inner_slot, ")\n\n"
    
    tSpeed = mill.speed
    bit_deg  = degrees_for_distance(slot_beg, spoke_dist)    
    if (is_inner_slot)
      bit_deg *= 1.5     
    end 
      
    adj_factor = start_zone_len / (slot_end - slot_beg)
    if (adj_factor > 1)
      bit_deg = bit_deg * adj_factor
      bit_deg = bit_deg * 1.1
    end
    
    degrees_for_bit_radius = degrees_for_distance(       
      slot_beg, mill.bit_radius)
    deg_for_adj2 = degrees_for_distance(slot_end, mill.bit_diam * 0.85)
    no_slots          = (360.0 / bit_deg).to_i
    deg_per_slot      = 360.0 / no_slots
    spoke_angle       = deg_per_slot * 0.45
    curr_deg = 0            
            
    mill.retract(pBeg_z + 0.1)
    ttse = (slot_end * 2) + mill.bit_radius
    if (ttse > cutout_diam)    
      ttse = cutout_diam
    end
      
    if (mill_circle_first == true)
      spiral_down_circle(
        mill, 
        x  =  pCent_x,
        y  =  pCent_y, 
        diam = ttse, 
        beg_z=0, 
        end_z=pEnd_z, 
        adjust_for_bit_radius=false, 
        outside=false, 
        auto_speed_adjust=false)        
    end
      
      
    mill.retract(pBeg_z)   
    for slot_no in (1..no_slots)
      print "(mill slot num = ", slot_no, ")\n"
      mill.retract()
      end_angle = curr_deg +  spoke_angle
      # the -1/2 bit_radius will cause my slots
      # from the next zone to reach into the air 
      # area
      #- mill.bit_radius * 0.1
      if (slot_no == no_slots)
        mill.set_speed(tSpeed * 0.9)
      else
        mill.set_speed(tSpeed)
      end
      if (is_inner_slot)
          print "(mill slots calling arc_to_radius  curr_deg=", curr_deg, "  end_angle=", end_angle, ")\n"
          arc_to_radius(mill, pCent_x, pCent_y, 
           slot_beg,
           curr_deg, 
           slot_end,  
           end_angle + deg_for_adj2, 
           pBeg_z, pEnd_z)       
          
         arc_to_radius(mill, pCent_x, pCent_y, 
           slot_beg, curr_deg,  
           slot_end, 
           end_angle - deg_for_adj2, 
           pBeg_z, pEnd_z)    
           
         arc_to_radius(mill, pCent_x, pCent_y, 
           slot_beg, curr_deg,  
           slot_end, 
           end_angle - deg_for_adj2 * 2, 
           pBeg_z, pEnd_z) 
            
          arc_to_radius(mill, pCent_x, pCent_y, 
           slot_beg, curr_deg,  
           slot_end, 
           end_angle + deg_for_adj2 * 2, 
           pBeg_z, pEnd_z)  
           
          arc_to_radius(mill, pCent_x, pCent_y, 
           slot_end, end_angle - (deg_for_adj2 *1.9),  
           slot_end, 
           end_angle + (deg_for_adj2 * 1.9) , 
           pBeg_z, pEnd_z)
                                                  
      else         
        arc_to_radius(mill, pCent_x, pCent_y, 
           slot_beg, curr_deg,  
           slot_end, 
           end_angle, 
           pBeg_z, pEnd_z)      
      end

                  
      curr_deg += deg_per_slot         
    end #for inner
    mill.set_speed(tSpeed)
    mill.retract(0.3)  
  end

  

   
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
     
     mill.retract()     
      
    
   
    # Outline of the wheel size to 
    # more readily show how things
    # will look when finished.
    mill.retract()
    mill.set_speed(tSpeed * 0.8)
  
    spiral_down_circle(mill = mill, 
         x  =  pCent_x,
         y  =  pCent_y, 
         diam = outline_diam, 
         beg_z=0, 
         end_z=blade_depth, 
         adjust_for_bit_radius=false, 
         outside=true, 
         auto_speed_adjust=false)
          
          
     # mill out transition zone
     # between inner and outer blade
     # patterns.       
     mill.retract()
     spiral_down_circle(mill, pCent_x, pCent_y, 
          entrance_area_diam, 
          0,
          0 - (blade_height), 
          false)
     mill.set_speed(tSpeed)
     mill.retract() 
 
       
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
     spiral_down_circle(mill, pCent_x, pCent_y, 
          outline_diam, 
          0,
          0 - (blade_height), 
          false)    
     mill.set_speed(tSpeed)   
                   
     mill.retract(0.5)      
     mill.pause("Please place 3/16 bit and adjust for 0.75on Z to surface")
     bit2 = CNCBit.new(mill, "config/bit/carbide-0.1875X0.50X1.5-2flute.rb")

  
     #bit2 = CNCBit.new(mill, "config/bit/carbide-0.250X0.75X2.5-6flute.rb")
     old_bit = mill.curr_bit
     mill.curr_bit = bit2
     bit2.recalc()
     mill.curr_bit.adjust_speeds_by_material_type(material_type)
     
     
     mill.retract()
     
     mill_impeller_axel(pCent_x, pCent_y)
     

     
     # Finish the coutout job with the last
     mill.set_speed(tSpeed * 0.8)
     mill.retract()

     #TODO: Change this over to the cutout 
     # which leaves tabs.
     spiral_down_circle(mill = mill, 
         x  =  pCent_x,
         y  =  pCent_y, 
         diam = cutout_diam, 
         beg_z=blade_depth, 
         end_z=drill_through_depth * 0.97, 
         adjust_for_bit_radius=false, 
         outside=true, 
         auto_speed_adjust=false)
             
      mill.set_speed(tSpeed)
     mill.retract()
     mill.curr_bit = old_bit
     old_bit.recalc()
     mill.retract()
     mill.home()    
            
   
  end #meth  mill_pump_wheel


  
   
  #  Mill a simple pump wheel lid which 
  #  This is so simple that we do not need
  #  to mill a custom mirrored verison because
  #  it will fit either way.
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_pump_wheel_lid(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
     print "(mill_pump_wheel_lid)\n"  
     mill.retract()
     
     print "(L995 - shaft_diam = ", shaft_diam, ")\n"
    
     mill_impeller_axel(pCent_x, pCent_y, mirrored=false, pBegZ=0, pEndZ=nil)
     
          
     # Coutout job with the last    
     mill.retract()
  
     # TODO: change this over to cutout that leaves tabs
     spiral_down_circle(mill = mill, 
         x  =  pCent_x,
         y  =  pCent_y, 
         diam = cutout_diam, 
         beg_z=0, 
         end_z=drill_through_depth * 0.97, 
         adjust_for_bit_radius=false, 
         outside=true, 
         auto_speed_adjust=false)
          
     mill.retract()
     mill.home()    
            
   
   end #meth  mill_pump_wheel_lid
   
   
   
  
  # # # # # # # # # # # # # # # # # #
  def impeller_hub_nut(pCent_x, pCent_y, pThick)
  # # # # # # # # # # # # # # # # # #
      
     spoke_width       = wall_thick  
     spoke_dist        = mill.bit_radius + (spoke_width * 1.1)             
     pEndZ = 0 - pThick.abs
          
 
     mill_impeller_axel(pCent_x, pCent_y,0,0, drill_through_depth)
                    
     mill.retract()                  
     num_air_entry = 4         
     mill_radial_blades(mill, 
         pCent_x,
         pCent_y, 
         impeller_hub_mill_diam,  
         air_entry_end_diam + mill.bit_radius,   
         0, drill_through_depth, 
         num_air_entry,
         spoke_dist)
           
         
     # TODO:  Make the rim wall sloped so inside to outside
     #  so air hitting it off the blades is encouraged
     #  to flow into the impeller.
     
     
     # Finish the coutout job with the last    
     # Cut most of the way through but with an cut
     # increments so we leave stock for a finish pass.                        
     mill.retract()                   
     #cut_out_impeller(pCent_x, pCent_y) 
     cut_out_circ_nub(
       pCent_x, 
       pCent_y, 
       pDiam   = impeller_hub_nut_mill_diam, 
       pBegz   = 0, 
       pEndZ   = pEndZ)    
                   
     mill.retract()         
     mill.home()    
      
   
  end #meth  

   # # # # # # # # # # # # # # # # # #
  def impeller_radial(pCent_x, pCent_y, pDiam, pNumFins, pRimThick, pHubDiam,  pShaftDiam, pThick)
  # # # # # # # # # # # # # # # # # #
  
    spoke_dist        = mill.bit_radius + (wall_thick * 1.1)             
    pEndZ = 0 - pThick.abs          
    air_beg = pHubDiam + mill.bit_diam
    air_end = pDiam - (mill.bit_diam +  (pRimThick * 2))
    
    mill.retract()          
       aCircle = CNCShapeCircle.new(mill)
       #print "(ZZZZZZZZZZZZ pBegZ=", pBegZ, ")\n"
       aCircle.beg_depth = 0 
       aCircle.mill_pocket(
         pCent_x, 
         pCent_y, 
         pShaftDiam, 
         pEndZ ,  
         island_diam=0)
         
                    
     mill.retract()                  
         
     mill_radial_blades(mill, 
         pCent_x,
         pCent_y, 
         air_beg,  
         air_end,   
         0, pEndZ, 
         pNumFins,
         spoke_dist)
           
         
     # TODO:  Make the rim wall sloped so inside to outside
     #  so air hitting it off the blades is encouraged
     #  to flow into the impeller.
     
     
     # Finish the coutout job with the last    
     # Cut most of the way through but with an cut
     # increments so we leave stock for a finish pass.                        
     mill.retract()                   
     #cut_out_impeller(pCent_x, pCent_y) 
     cut_out_circ_nub(
       pCent_x, 
       pCent_y, 
       pDiam   = pDiam + mill.bit_diam, 
       pBegz   = 0, 
       pEndZ   = pEndZ)    
                   
     mill.retract()         
     mill.home()    
      
   
  end #meth  
  
  
  
   

end # end Module