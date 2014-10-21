module Pump_centrifuge_impeller_simple

 #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  # Customized Wheel that maximises air flow
  #  #   At periphery based on a given wheel size.
  #  #   Basically mills out the inlet pockets 
  #  #   which are 30% of the wheel diameter.
  #  #   Then is wheels a series of short fins
  #  #   Each of which is 3 bit diameters long
  #  #   separted by a circle of 1 bit diameter
  #  #   Then another set of fins.  We always
  #  #   have as many fins as will fit at each
  #  #   Zone.  The inner fins help move the 
  #  #   the outer fins which are responsible
  #  #   for the final expel.  By maximizing
  #  #   The number of fins at each zone we 
  #  #   maximize the centrifuge force for
  #  #   each one.
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_simple_pump_wheel(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
     print "(mill_simple_pump_wheel)\n"
     tSpeed = mill.speed()
     tCutDepthInc = mill.cut_depth_inc
     cutDepthIncAdj = 1.0
                       
     #mill.load_bit("config/bit/carbide-0.1875X0.50X1.5-2flute.rb", "Please place 3/16 bit and adjust for 0.75on Z to surface", 0.5, material_type)
               
     print "(520 wall_thick = ", wall_thick, ")\n"    
      
     print "(699 blade_depth=", blade_depth, ")\n"     
               
     curr_depth   = 0
  
     # Mill out our axel / shaft 
     # hole.
     old_bit = aMill.curr_bit
     mill.retract()
     
     print "(L445 - shaft_diam = ", shaft_diam, ")\n"
     aCircle = CNCShapeCircle.new(aMill)
     if (shaft_type == "D")
       mill_DDShaft(aMill, 
          x = pCent_x,
          y = pCent_y, 
          diam = shaft_diam, 
          beg_z = 0.0, 
          end_z = drill_through_depth, 
          adjust_for_bit_radius=true)
     else # round axel 
        print "(milling round axel)\n"
        aMill.retract()                 
        aCircle.beg_depth = 0         
        aCircle.mill_pocket(pCent_x, pCent_y, shaft_diam, 
          drill_through_depth ,  
          island_diam = 0)          
     end
       
     air_mix_depth = stock_z_len * 0.9
           
     # now we need the area to allow the inlet air to 
     # mix after coming through the holes.
     #print "\n\n(Air Mixing Area at bottom of wheel)\n"
     aCircle.beg_depth = curr_depth
     pbot = curr_depth - (air_mix_depth * 0.2);
     
     idiam = (hub_diam + air_entry_end_diam) / 2.0
     
     # keeps the taller finds 1/2 way out 
     # to help give the inner air some
     # momentum
     #aCircle.mill_pocket(pCent_x, pCent_y, 
     #  air_entry_end_diam, 
     #  blade_depth,
     #  island_diam =  idiam)
     #curr_depth = pbot
   
    if (mirror_impellor == false)
      air_entrance_depth = drill_through_depth
    else
      air_entrance_depth = blade_depth
    end
    
     #### Mill the exit air pockets to
     #### accept air from oposite side.   
     #print "\n\n(AIR ENTRY arc segments)\n"
     tDiam = shaft_diam + wall_thick + mill.bit_diam
     if (tDiam > hub_diam)
       tDiam = hub_diam
     end
     
     center_air_entry_arc_pockets(
       pCent_x = pCent_x, 
       pCent_y = pCent_y, 
       inner_diam = tDiam, 
       outer_diam = air_entry_end_diam,  
       num_pockets = 6, 
       beg_z = 0,  
       end_z = air_entrance_depth, 
       spike_width = wall_thick * 1.5)
    

     
     curr_beg_diam   = air_entry_end_diam + (mill.bit_radius * 0.8)
     curr_beg_radius = curr_beg_diam / 2.0
     # TODO: spoke_width_This should be set based on a expected RPM
     # and material hardness rather than a arbitrary #     
     spoke_width     = mill.bit_diam / 2.0       
     spoke_len       = mill.bit_diam * 2
     region_cnt = 0
     
     # the larger the wheel the more careful I need to
     # be on the cutout so we deduct 10% of the normal cut
     # depth for each inch in size.
     adjCutDepthInc = tCutDepthInc - (tCutDepthInc * (0.02 * wheel_diam))
     
     orig_beg_radius = curr_beg_radius
     while (true)
      #  loop through each of the regions.
      region_cnt += 1
      spoke_len = spoke_len * 1.1
      curr_end_radius = curr_beg_radius + spoke_len  
       if (curr_end_radius > cutout_radius)
         curr_end_radius = cutout_radius
       elsif (curr_end_radius + (spoke_len * 0.6)) > cutout_radius
         curr_end_radius = cutout_radius
       end       
               
       #print "(spoke_width=", spoke_width, ")\n"
       spoke_dist = mill.bit_diam + spoke_width
       #print "(spoke_dist=", spoke_dist, ")\n"     
       bit_deg = degrees_for_distance(curr_beg_radius, spoke_dist)          
       #print "(bit_deg=", bit_deg, ")\n"
            
       no_slots = (360.0 / bit_deg).to_i
       deg_per_slot = 360.0 / no_slots
       spoke_angle = deg_per_slot * 0.85
                        
       #print "(no_slots = ", no_slots, ")\n"
       #print "(deg_per_slot = ", deg_per_slot, ")\n"
       #print "(spoke_angle  = ", spoke_angle, ")\n"
       main_slot_end_radius =  wheel_radius + mill.bit_radius
      
       if (region_cnt == 1)
         depth_adjust = 0.85
       else
         depth_adjust = 1.0
       end
          
       mill.retract()
       mill.set_speed(tSpeed * 0.9)
       if (curr_beg_radius == orig_beg_radius)
         mill.retract()
         mill.set_cut_depth_inc(adjCutDepthInc)
           spiral_down_circle(aMill, pCent_x, pCent_y, 
              curr_beg_radius * 2, 
              0,
              blade_depth * depth_adjust, 
            false) 
       end
       mill.retract()
       mill.set_cut_depth_inc(adjCutDepthInc)
           spiral_down_circle(aMill, pCent_x, pCent_y, 
              curr_end_radius * 2, 
              0,
              blade_depth * depth_adjust, 
            false) 
       
       mill.set_speed(tSpeed)
       mill.set_cut_depth_inc(tCutDepthInc)
       
       # Mill out as many slots as we can fit
       # in the current wheel.   Roughly
       # 30% of the center of each wheel will
       # be for air holes.
       if (mirror_impellor == true)
         curr_deg = 360
       else
         curr_deg = 0        
       end
       for slot_no in (1..no_slots)
         aMill.retract()
         if (mirror_impellor == true)
           end_angle = curr_deg + spoke_angle
         else
           end_angle = curr_deg - spoke_angle
         end
         #print "(slot_no=", slot_no, ")\n"
         #print "(curr_deg=", curr_deg, ")\n"
         #print "(end_angle =", end_angle, ")\n"
         #print "(blade_depth=", blade_depth, ")\n"
         # mill the full arc all the way to the edge     
         arc_to_radius(mill, pCent_x, pCent_y, 
           curr_beg_radius,  curr_deg, 
           curr_end_radius,  end_angle, 
           0, blade_depth)                       
         if (mirror_impellor == true)  
           curr_deg -= deg_per_slot         
         else
           curr_deg += deg_per_slot         
         end
       end #for inner
   
            
       if (curr_end_radius == cutout_radius)
         break
       else
         curr_beg_radius = curr_end_radius
       end
       
     end # while fin rows
          
     # Finish the coutout job with the last    
     # Cut most of the way through but with an cut
     # increments so we leave stock for a finish pass.   
     mill.retract()
     mill.set_speed(tSpeed * 0.8)
     spiral_down_circle(aMill, pCent_x, pCent_y, 
          cutout_diam, 
          blade_depth,
          drill_through_depth * 0.97, 
          false)   
          
     mill.set_speed(tSpeed)
     aMill.retract()
     mill.curr_bit = old_bit
     old_bit.recalc()
     aMill.retract()
     aMill.home()    
            
   
   end #meth  mill_simple_pump_wheel
  

end #module

