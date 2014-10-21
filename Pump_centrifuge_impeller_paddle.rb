require 'radial_fan'

#
#  This one is designed to use an alternative
#  paddle volute design.  We will use a flat
#  sheet of material and then a 0.7" tall strip
#  which is placed in two pieces in the increasing
#  volute which end at the edge of the plastic.  A 
#  front pannel made of heavier matieral will be
#  solvent bonded and the top can have the simple
#  air inlet box through the motor.  Used in this
#  fashion we will still waste a lot of materia for
#  the impeller but main pump body will not be nearly as
#  expensive.  
#
#  In an ideal implemention we would trace the channel
#  for placement of the main area of the volute using 
#  the mill rather than having to hand place that way
#  the solvent bond is much simpler place the strip in
#  the slot and bond.    The problem with this is that
#  if we use a 5.2" wheel we can not get the mill in a 
#  single step to make the trace because it will be 
#  to large so we would have to turn the part around,
#  re-align and and then finish the trace but then the
#  remaining trace would have to be done in reverse
#  but if have them place at end of prior item should
#  not be too difficult.

module Pump_centrifuge_impeller_paddle

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  
  def start_zone_len
  #  #  #  #  #  #  #  #  #  #  #  #  #  #  
    return mill.bit_diam * 2.1
  end
  
  #  #  #  #  #  #  #  #  #  #  #  #  #  #  
  def max_zone_len
  #  #  #  #  #  #  #  #  #  #  #  #  #  #  
    return start_zone_len * 3
  end

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  
  def start_slot_beg   
  #  #  #  #  #  #  #  #  #  #  #  #  #  #    
   return  hub_radius + mill.bit_radius
  end
  
  #  #  #  #  #  #  #  #  #  #  #  #  #  #  
  def spoke_width
  #  #  #  #  #  #  #  #  #  #  #  #  #  #    
    return  wall_thick 
  end
  
  #  #  #  #  #  #  #  #  #  #  #  #  #  #  
  def spoke_dist
  #  #  #  #  #  #  #  #  #  #  #  #  #  #    
    return  (mill.bit_radius * 2)+ (spoke_width * 1.3)
  end
            

  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  #  Most of the cheaper blower fans have
  #  3 or 4 straight paddles with the center
  #  empty.    This version is similar but
  #  with smaller spaces and more paddles.
  # 
  #  Enhanced with paddles in the center that
  #  start in the center and go towards the
  #  main fins. 
  # 
  #
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_paddle_impeller(pCent_x, pCent_y)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
     mill.curve_granularity = 0.02 #0.22 #0.006
     #mill.curve_granularity = 0.006
    
      print "(mill_small_diameter_pump_wheel material_type=", material_type, ")\n"      
      print "(wheel_diam=", wheel_diam,  " stock_z_len=", stock_z_len, ")\n"      
      print "(shaft_diam=", shaft_diam, ")\n" 
      print "(hub_diam=", hub_diam, ")\n"
      print "(air_entry_end_diam=", air_entry_end_diam, ")\n"
      print "(wall_thick = ", wall_thick, ")\n"
      print "(stock_z_len=", stock_z_len, ")\n"
      print "(blade_height=", blade_height, ")\n"  
                
     mill.retract()     
     
     if (1 == 0)
       # test the axel
       mill.retract()
       mill_axel_with_approapriate_sized_bit(0.1, 0.1)  
       mill.retract(0.3)      
       return     
     end
     
     
     restart_flag = false
     if (restart_flag == true)
       # Allow stop for secondary alignment
       mill.retract()
       mill.move_fast(pCent_x, pCent_y)
       mill.plung(0.01)
       mill.pause("Check for mill. bit centered over axel")
       mill.retract()
                
       
     else
       # NEW Job need to mill the axel
       mill.retract()
       mill_axel_with_approapriate_sized_bit(pCent_x, pCent_y)  
       mill.retract()   
       mill.move(pCent_x, pCent_y)
       mill.plung(-0.005)
       mill.retract(0.3)      
       
       # Produce an Alignment Hole Allow easy Manual
       # alignment if have to restart the job
       mill.retract(0.3)
       mill.move_fast(0,0)
       align_depth = -0.3
       if (align_depth <  drill_through_depth)
         align_depth = drill_through_depth
       end
       mill.drill(0,0,0, align_depth)     
       mill.retract(0.3) 
     end
     
     
     
     # Trace outer circle to make sure 
     # everything will fit as aligned.
     mill.retract(0.3)
     #spiral_down_circle(
     #    mill, 
     #    x  =  pCent_x,
     #    y  =  pCent_y, 
     #    diam = cutout_diam, 
     #    beg_z=0, 
     #    end_z=blade_height, 
     #    adjust_for_bit_radius=false, 
     #    outside=false, 
     #    auto_speed_adjust=false)        
     # mill.retract()
     
     
     zone_len       = start_zone_len        
     slot_beg       = start_slot_beg
     orig_slot_beg  = slot_beg
     #slot_beg       += zone_len
     max_slot       = cutout_diam / 2.0
     tSpeed = mill.speed
     while (true)     
       slot_end = slot_beg + zone_len
       if (slot_end + zone_len * 0.6) > max_slot
         # if next zone would be less than
         # full length then combine this
         # zone with the next one
         slot_end = max_slot
       end  
      
       if (orig_slot_beg == slot_beg)
        is_inner_slot = true
       else
        is_inner_slot = false
       end
       mill.retract(0.3)
       mill_slots(
          pCent_x, pCent_y,
          slot_beg,  slot_end, 
          0, 0 - blade_height.abs, 
          spoke_dist, is_inner_slot)
             
       if (slot_end == max_slot)
         break
       else
         if (zone_len < max_zone_len)
           zone_len = zone_len * 1.3
         end
         slot_beg   += zone_len        
       end
     end # while slots
     
     mill.retract()  
     
     # Finish the coutout job with the last    
     # Cut most of the way through but with an cut
     # increments so we leave stock for a finish pass.              
             
     cut_out_circ_nub(pCent_x, pCent_y, pDiam=cutout_diam, pBegZ=blade_height, pEndZ=drill_through_depth)
                       
     
     #mill.set_speed(tSpeed)
     mill.retract()         
     mill.home()    
      
   
  end #meth  mill_small_pump_wheel

 
 
       
  #  Mill a simple pump wheel lid which 
  #  This is so simple that we do not need
  #  to mill a custom mirrored verison because
  #  it will fit either way.
  #
  #   TODO:  Need to add a center with 4 pockets
  #    that can be utilized to hole a axel hub.
  #    Can use the sloped radial fan strategy
  #    previously developed for hub nuts.
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def mill_paddle_impeller_lid(pCent_x, pCent_y, pBegZ, pEndZ)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
     print "(mill_paddle_impeller_lid)\n"            
     print "(shaft_diam = ", shaft_diam, ")\n"
     print "(pCent_x = ", pCent_x, " pCent_y=", pCent_y, ")\n"
     print "(pBegZ=", pBegZ, " pEndZ=", pEndZ, ")\n"
     if (pEndZ == nil)
       pEndZ = 0 - drill_through_depth
     end
     if (pEndZ > 0)
       pEndZ = 0 - pEndZ
     end
     if (pBegZ > 0)
       pBegZ = 0 - pBegZ
     end
     print "(pCent_x = ", pCent_x, " pCent_y=", pCent_y, ")\n"
     print "(pBegZ=", pBegZ, " pEndZ=", pEndZ, ")\n"

     
     raised_ring_out_diam = (air_entry_end_diam  * 1.2)+ wall_thick     
     tCD = mill.cut_depth_inc
     net_depth = (pEndZ - pBegZ).abs
     no_less_025 = 0.25 / net_depth
     if (no_less_025 > 1)
       mill.cut_depth_inc = tCD / (no_less_025 * 2)
     end    
    
     mill.retract()
     mill_axel_with_approapriate_sized_bit(pCent_x, pCent_y)              
     zone_len       = start_zone_len    
     slot_beg       = start_slot_beg
          
     mill_slots(
          pCent_x, pCent_y,
          slot_beg,  air_entry_end_radius * 1.2, 
          pBegZ, pEndZ, 
          spoke_dist,
          is_inner_slot = true,
          mill_circle_first = false)          
                    
     mill.retract()                  
           
         
     # TODO:  Make the rim wall sloped so inside to outside
     #  so air hitting it off the blades is encouraged
     #  to flow into the impeller.     
     
         
     curr_diam = air_entry_end_diam * 1.2
     groove_depth = drill_through_depth * 0.15
     while (true)
       # We have to spiral down early
       # because otherwise it seems to 
       # chip the end of the fins when
       # milling brittle materials.     
       mill.retract()
       curr_diam += mill.bit_diam * 2.5 + wall_thick * 2.5
       if (curr_diam + (mill.bit_diam * 1.5)) > cutout_diam
         break
       else
         mill.retract(1.0) # Give the bit some cooling time
         spiral_down_circle(
            mill, 
            x  =  pCent_x,
            y  =  pCent_y, 
            diam = curr_diam, 
            beg_z=0, 
            end_z=groove_depth, 
            adjust_for_bit_radius=false, 
            outside=false, 
            auto_speed_adjust=false)  
          
         # trace in reverse to clean
         # up the grove     
         #print "(Reverse trace t clean up the grove)\n"
         mill.retract(1.0) # give the bit some cooling time
         spiral_down_circle(
            mill, 
            x  =  pCent_x,
            y  =  pCent_y, 
            diam = curr_diam, 
            beg_z=groove_depth, 
            end_z=groove_depth, 
            adjust_for_bit_radius=false, 
            outside=true, 
            auto_speed_adjust=false)  
              
       end #else
     end # while
      
     mill.retract() 
     
                                 
     # Coutout job with the last    
     mill.retract()       
     #mill.cut_depth_inc = tCD / 2.0
     print "\n\n(perform cutout circle)\n\n"
     #spiral_down_circle(
     #       mill, 
     #       x  =  pCent_x,
     #       y  =  pCent_y, 
     #       diam = cutout_diam, 
     #       beg_z=0, 
     #       end_z=drill_through_depth,      
     #       adjust_for_bit_radius=false, 
     #       outside=false, 
     #       auto_speed_adjust=false)
     tSpeed = mill.speed
     mill.set_speed(tSpeed / 2.5)
     cut_out_circ_nub(pCent_x, pCent_y)
     mill.set_speed(tSpeed)
     mill.cut_depth_inc = tCD          
     mill.retract()
     mill.home()    
  end #meth
            
  
   #   #   #   #   #   #   #   #   #
   # This mills the air inlet holes for the difusser
   # with the assumption that we will not utilze 
   # a flow back tortous path.    The assumption
   # is that the flute area will be manually molded
   # aroud the blade to shape the diffuser. 
   #   #   #   #   #   #   #   #   #
   def mill_paddle_body_lid(pCent_x, pCent_y, pBegZ=0, pEndZ=nil, include_bearing=false, shaft_size=0.25)
   #   #   #   #   #   #   #   #   #
      print "(mill tesla lid)\n"
      print "(This item is mirrored on the X axis to the)\n"
      print "(bolt pattern, bearing support and axel to the)\n"
      print "(body so that when flipped over the bolt pattern matches)\n"
      
     
      
      
     if (pEndZ == nil)
       pEndZ = 0 - drill_through_depth
     end
     if (pEndZ > 0)
       pEndZ = 0 - pEndZ
     end
     if (pBegZ > 0)
       pBegZ = 0 - pBegZ
     end
     lcx = pCent_x
     lcy = pCent_y
     
     curr_depth = 0       
     cut_through = pEndZ
     net_depth = pEndZ - pBegZ    
     cavity_depth =  pBegZ - (net_depth / 3.0).abs
     
     
    
     
     
     mill.retract()          
     # Drill the axel hole all the way 
     # through  This is the little gold
     # center part of the motor
     aCircle.beg_depth = cavity_depth
     aCircle.mill_pocket(pCent_x, pCent_y, 
       0.30, 
       pEndZ, 
       island_diam=0)   
     mill.retract()   
     
     counter_sink_depth = cavity_depth - (net_depth * 0.2).abs
     
     # mark and counter sink for holes 
     # for screws          
     mill.retract() 
     bolt_sep = 1.04
     bolt_sep_radius = bolt_sep / 2.0
     aCircle.beg_depth = 0
     aCircle.mill_pocket(
       pCent_x + bolt_sep_radius, 
       pCent_y, 
       0.2,  
       counter_sink_depth,        
       island_diam=0)   
     mill.retract()          
     aCircle.mill_pocket(
       pCent_x - bolt_sep_radius,
       pCent_y, 
       0.2,  
       counter_sink_depth,        
       island_diam=0)         
     mill.retract() 
       
     
     # Mill the center air entrance pocket
     # with 4 fairly wide spokes to support
     # the motor. 
     num_pocket = 4.0
     degrees_per_pocket = 360 / num_pocket
     beg_degree = 0
     pocket_air_width = degrees_per_pocket * 0.30
     beg_degree = (degrees_per_pocket -  pocket_air_width) / 2.0
     degree_advance =  degrees_for_distance(air_entry_end_radius, mill.bit_radius) * 1.5
     no_deg_step = 360 / degree_advance
     gap_every = no_deg_step / 6
     curr_degree = -40  
     seg_adv = 115   
     slot_beg = hub_radius + wall_thick + (mill.bit_radius * 2)
     slot_end = (air_entry_end_radius + mill.bit_radius) * 1.1
     mill.retract()         
     while (curr_degree < 50)     
       arc_to_radius(mill, pCent_x, pCent_y, 
         slot_beg,
         curr_degree,
         slot_end, 
         curr_degree,
         pBegZ, pEndZ)  
       
       curr_degree +=  degree_advance                  
     end
     arc_to_radius(mill, pCent_x, pCent_y, 
         slot_end,
         -35,
         slot_end, 
         45,
         pBegZ, pEndZ)         
     arc_to_radius(mill, pCent_x, pCent_y, 
         slot_beg,
         -35,
         slot_beg, 
         45,
         pBegZ, pEndZ)         
     
     
     mill.retract()         
     curr_degree = 130       
     while (curr_degree < 220)     
       arc_to_radius(mill, pCent_x, pCent_y, 
         slot_beg,
         curr_degree,
         slot_end, 
         curr_degree,
         pBegZ, pEndZ)         
       curr_degree +=  degree_advance                  
     end
     mill.retract()         
     arc_to_radius(mill, pCent_x, pCent_y, 
         slot_end,
         135,
         slot_end, 
         215,
         pBegZ, pEndZ)         
     arc_to_radius(mill, pCent_x, pCent_y, 
         slot_beg,
         135,
         slot_beg, 
         215,
         pBegZ, pEndZ)         
     
          
     
     # Mill the outlet 
     
     mill.retract()         
     xpos_of_outlet = 13
     ypos_of_outlet = 4
     mill.retract()
     aCircle.beg_depth = cavity_depth
     aCircle.mill_pocket(xpos_of_outlet, ypos_of_outlet, 
       entrance_diam, 
       pEndZ, 
       island_diam=0)                 
     mill.retract()     
     
     
     # Drill mounting holes for one side
     bolt_sep = 1.04
     bolt_sep_radius = bolt_sep / 2.0
     aCircle.beg_depth = 0
     
     aCircle.mill_pocket(0.3, 0.3, 
       0.2,  
       pEndZ,        
       island_diam=0)   
     mill.retract()          

     
     aCircle.mill_pocket(6.5 , 0.2, 
       0.2,  
       pEndZ,
       island_diam=0)            
     mill.retract()          

          
     aCircle.mill_pocket(13.7,  0.3,
       0.2,  
       pEndZ,        
       island_diam=0)   
     mill.retract()  


     # remove 1/2 cirlce worth of cavity.  The rest will 
     # have to be removed after the part is rotated 
     mill_half_circle(pCent_x, pCent_y, cavity_diam, 0, cavity_depth)     
  

     mill.retract()     
     mill.move(pCent_x, pCent_y)
     mill.plung(0.05)
     print "(Remove second have of cavity.  Alignment is over axel hole)\n"    
     print "(May require manual alignment of table)\n"
     mill.pause("Rotate Part 180 degrees and center over axel hole");
     # remove 1/2 cirlce worth of cavity.  The rest will 
     # have to be removed after the part is rotated 
     mill_half_circle(pCent_x, pCent_y, cavity_diam, 0, cavity_depth)
     mill.retract()           
     mill.home()
   end # mill_lid method

    #   #   #   #   #   #   #   #   #
   
   #   #   #   #   #   #   #   #   #
   def mill_half_circle(pCent_x, pCent_y, pDiam, pBegZ, pEndZ)
   #   #   #   #   #   #   #   #   #
    
   
     if (pEndZ == nil)
       pEndZ = 0 - drill_through_depth
     end
     if (pEndZ > 0)
       pEndZ = 0 - pEndZ
     end
     if (pBegZ > 0)
       pBegZ = 0 - pBegZ
     end
     lcx = pCent_x
     lcy = pCent_y
     curr_radius =  (pDiam / 2.0) - mill.bit_radius

     mill.retract()    
     min_radius = mill.bit_radius / 2
      
     while (true)           
     
       arc_to_radius(mill, pCent_x, pCent_y, 
         curr_radius,
         0,
         curr_radius, 
         95,
         pBegZ, pEndZ)  
         
       arc_to_radius(mill, pCent_x, pCent_y, 
         curr_radius,
         0,
         curr_radius, 
         -95,
         pBegZ, pEndZ)  
         
       if (curr_radius == min_radius)
         break
       end
         
       curr_radius -=  mill.bit_diam * 0.9                  
       if (curr_radius < min_radius)
         curr_radius = min_radius
       end
       
     end

     
   end # mill_lid method

 

end #module

