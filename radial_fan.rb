# test_pump_housing_1.5_inch.rb
#
require 'cncMill'
require 'cncGeometry'
require 'cncShapeBase'
require 'cncShapeArc'
require 'cncShapeSpiral'
require 'cncShapeCircle'
require 'cncShapeRect'


 
   # Mill a fan blade out that has a sloping
   # portion for each blade separated
   # by an air space portion between the
   # blades. 
   # We use a different stategy for milling these
   # sloping fan blades.  We basically
   # mill off the flat surface for each blade in
   # our standard cut depth incrments and then
   # mill off the next layer but skip any portion
   # of the blade that is above the new plane.
   # the intent is to minimize movment of the
   # bit in space where it isn't cutting anything
   #
   # TODO: Need to be able to reverse this so the 
   #  blades are angled the oposite direction
   # 
   # TODO: Need an algorithm that does this work
   #    without leaving the lines.  At one time Joe
   #    wrote one that left highly polished surface
   #    but could not find it.  It involved arching
   #    from inside to outside on one pass and side
   #    to side on the next pass. and arching at a
   #    diagnal on another to keep the lines fully
   #    randomized.
   #   
   #  TODO:  need a faster implementation the existing
   #    one takes way too long.  One option would be
   #    to work down to each layer of the curve starting
   #    at the shallow end and arching from one end 
   #    to the other at the same depth.  Then moving
   #    one step closer to deep end and arching to
   #    doing the next layer and then comming back and
   #    milling the slope diagnals with something like
   #    1/100 of a cut increment.
   #   #   #   #   #   #   #   #   #
   def mill_radial_blades(mill, lcx, lcy, inside_diam,  outside_diam,   pbeg_z, pend_z, num_blades, spoke_thick=0.1)
   #   #   #   #   #   #   #   #   #

     tSpeed = mill.speed       
     if (pbeg_z > 0)
       pbeg_z = 0 - pbeg_z
     end

     if (pend_z > 0)
       pend_z = 0 - pend_z
     end
           
     blade_to_air_space_ratio = 0.80
     space_between_blade = spoke_thick 
     beg_diam   = inside_diam 
     lbeg_radius = beg_diam / 2.0
     lend_radius = outside_diam / 2.0
     radius_delta = lend_radius - lbeg_radius
     num_bit_passes_in_radius = radius_delta / mill.cut_inc
     degrees_for_space_inner = degrees_for_distance(lbeg_radius, space_between_blade)     
     degrees_for_space_outer = degrees_for_distance(lend_radius, space_between_blade)     
     fan_blade_total_space = (360.0 / num_blades.to_i)     
     usable_blade_space = fan_blade_total_space  - degrees_for_space_outer    
     fan_blade_width = usable_blade_space  * blade_to_air_space_ratio      
     fan_blade_air_space = usable_blade_space - fan_blade_width
     degrees_delta = degrees_for_space_outer - degrees_for_space_inner     
     degrees_change_per_pass = (degrees_delta / num_bit_passes_in_radius).abs

   
     print "(mill_radial_blades)\n"
     print "(inside_diam=", inside_diam, ")\n"
     print "(outside_diam=", outside_diam, ")\n"
     print "(num_blades=", num_blades, ")\n"
     print "(spoke_thick=", spoke_thick, ")\n"
     print "(lbeg_radius=", lbeg_radius, ")\n"
     print "(lend_radius=", lend_radius, ")\n"
     print "(space_between_blade=", space_between_blade, ")\n"     
     print "(num_blades = ", num_blades, ")\n"
     print "(fan_blade_total_space =", fan_blade_total_space, ")\n"
     print "(degrees_for_space_outer=", degrees_for_space_outer, ")\n"
     print "(fan_blade_air_space=", fan_blade_air_space, ")\n"     
     print "(space between bladed inner = ", degrees_for_space_inner, ")\n"
     print "(space between blades outer =", degrees_for_space_outer, ")\n"  
     print "(degree_change_per_cut_inc=", degrees_change_per_pass, ")\n"
     print "(bit_radius=", mill.bit_radius, ")\n"
     print "(inner radius=", lbeg_radius,")\n"
     print "(outer radius=", lend_radius,")\n"
     print "(pbeg_z  = ", pbeg_z, ")\n"
     print "(pend_z  = ", pend_z, ")\n"
     
        
     # move in by bit_diam to prevent cutting into vice    
     mill.retract() 
     # Work around the wheel and mill out 
     # the fan blades
     fan_blade_beg = 0 
     cmz = pbeg_z
     t_cut_depth_inc = mill.cut_depth_inc * 0.99
     tot_cut_depth = pbeg_z - pend_z     
     blade_circumf = calc_circumference(lend_radius) / num_blades
     #if (blade_circumf < 1)
     #  t_cut_depth_inc *= blade_circumf
     #end

     print "(number of depth passes required = ",  tot_cut_depth / t_cut_depth_inc, ")\n"
     
     while (( fan_blade_beg + fan_blade_total_space) <= 360)
       print "(fan_blade_beg = ", fan_blade_beg, ")\n"
       # Number of blades
       mill.retract()       
       pass_cnt = 0       
             
       mill.retract()
       # Mill the sloping down portin of
       # the blades Stoppoing 0.04 before
       # going thorugh
       degree_per_step = 1.5 
       cmz = pbeg_z
       air_end_deg_in = nil
       air_end_deg_out= nil
       air_beg_deg_in = nil
       air_beg_deg_out = nil
       tCut_inc = mill.cut_inc
       tPass_mult = 0.7
       while true     
         print "(cmz=", cmz,  " pbeg_z=", pbeg_z, " pend_z=", pend_z, " cut_depth_inc=", mill.cut_depth_inc, " )\n"
         # work down through the layers                   
         curr_in_deg = fan_blade_beg
         curr_out_deg = fan_blade_beg
         step_cnt = 0
         curr_radius = lend_radius        
         pass_end_deg = (fan_blade_beg + fan_blade_width)  
         pass_air_space = fan_blade_air_space
         degrees_change_per_pass
         cmz -= t_cut_depth_inc
         if cmz <  pend_z
            cmz = pend_z
            tCut_inc = tCut_inc / 5
            tPass_mult = tPass_mult / 5
         end

         while(true) 
           # Work from outside edge to inside edge                    
                          
           deg_per_bit_radius =  degrees_for_distance(curr_radius, mill.bit_radius)   
           # Mill the downward slope   
           # for the blade.            
           print "(curr_radius=", curr_radius, ")\n"
           print "(deg_per_bit_radius =", deg_per_bit_radius, ")\n"
                    
           changing_radius_curve(mill, lcx,lcy,
              beg_radius = curr_radius, 
              beg_degree = fan_blade_beg , 
              beg_z = 0.01 ,  
              end_radius = curr_radius, 
              end_degree = pass_end_deg, 
              end_z  =  cmz + 0.1,  
              degrees_per_step=degree_per_step,           
              skip_z_LT= nil, 
              skip_z_GT = nil)      

              
           # Mill the Air gap area
           # for the blade.                     
           changing_radius_curve(mill, lcx,lcy,
              beg_radius = curr_radius, 
              beg_degree = pass_end_deg, 
              beg_z = cmz ,  
              end_radius = curr_radius, 
              end_degree = pass_end_deg + pass_air_space, 
              end_z  =  cmz,  
              degrees_per_step=degree_per_step,           
              skip_z_LT= nil, 
              skip_z_GT = nil)  
              
                # Records the actual degrees used
           # for vertical wall of next fin
           air_end_deg_in = pass_end_deg + pass_air_space + 1
           if (air_end_deg_out == nil)
             air_end_deg_out =  air_end_deg_in
           end
           
           
           # Record actual degrees used 
           # for the front thin 
           # edge of the fin.  
           air_beg_deg_in = pass_end_deg - 2.0
           if (air_beg_deg_out == nil)
             air_beg_deg_out = air_beg_deg_in
           end
           
              
           # shift over so that when comming back
           # up we are also making a cut
           curr_radius  -= tCut_inc 
           if (curr_radius  < lbeg_radius)
               #print "(reset to beg_radius)"
              curr_radius = lbeg_radius
           end #if
           pass_end_deg   -=  (degrees_change_per_pass *tPass_mult)
           pass_air_space -=  (degrees_change_per_pass * tPass_mult)
           if (pass_end_deg < fan_blade_beg)
             fan_blade_beg = fan_blade_beg
           end
           if (pass_air_space < 0)
             pass_air_space = 0
           end
                
           # Mill Air gap Area traceback
           changing_radius_curve(mill, lcx,lcy,
             beg_radius = curr_radius, 
             beg_degree = pass_end_deg + pass_air_space , 
             beg_z = cmz,  
             end_radius = curr_radius, 
             end_degree = pass_end_deg,
             end_z  =  cmz,  
             degrees_per_step=degree_per_step,           
             skip_z_LT=  nil, 
             skip_z_GT = nil) 
             
                      
           # Traceback up the cureve
           changing_radius_curve(mill, lcx,lcy,
             beg_radius = curr_radius, 
             beg_degree = pass_end_deg , 
             beg_z = cmz + 0.01 ,  
             end_radius = curr_radius, 
             end_degree = fan_blade_beg, 
             end_z  =  0.01 ,  
             degrees_per_step=degree_per_step,           
             skip_z_LT=  nil, 
             skip_z_GT = nil)
                    
           if (curr_radius == lbeg_radius)
             curr_radius = lend_radius
             break
           else
             #print "(Curr Radius = ", curr_radius, ")\n"
             curr_radius  -= tCut_inc
             if (curr_radius  < lbeg_radius)
               #print "(reset to beg_radius)"
               curr_radius = lbeg_radius
             end #if
           end # else
           pass_end_deg   -=  (degrees_change_per_pass * tPass_mult)
           pass_air_space -=  (degrees_change_per_pass * tPass_mult)
           if (pass_end_deg < fan_blade_beg)
             fan_blade_beg = fan_blade_beg
           end
           if (pass_air_space < 0)
             pass_air_space = 0
           end
           
         end # while radius
         if (cmz == pend_z)
           break       
         end #else
        end #while depth
        
        # Trace the curve which is straight
        # on the blade to get ugly ridgest formed
        # during the milling of the sloped area
        print "(air_end_deg_in =", air_end_deg_in, ")\n"
        print "(air_end_deg_out=", air_end_deg_out,")\n"                   
        # Mill Air gap Area traceback
        mill.retract()
        changing_radius_curve(mill, lcx,lcy,
             beg_radius = lbeg_radius + 0.01, 
             beg_degree = air_end_deg_in , 
             beg_z  = pend_z + 0.001,  
             end_radius = lend_radius - 0.01, 
             end_degree = air_end_deg_out,
             end_z  =  pend_z,  
             degrees_per_step=0.1,           
             skip_z_LT=  nil, 
             skip_z_GT = nil) 
             
       # put a straight edge on fin
       # rather than the ragged one 
       # we get now
       mill.retract()
       changing_radius_curve(mill, lcx,lcy,
             beg_radius = lbeg_radius, 
             beg_degree = air_beg_deg_in , 
             beg_z  = pend_z + 0.001,  
             end_radius = lend_radius, 
             end_degree = air_beg_deg_out,
             end_z  =  pend_z,  
             degrees_per_step=0.05,           
             skip_z_LT=  nil, 
             skip_z_GT = nil) 
             
       fan_blade_beg += fan_blade_total_space
       fan_blade_end = fan_blade_beg + fan_blade_width
       mill.retract()
     end # while fan blades       
     mill.set_speed(tSpeed)
   end # method



 
   # Mill a fan blade out that has a sloping
   # portion for each blade separated
   # by an air space portion between the
   # blades. 
   # We use a different stategy for milling these
   # sloping fan blades.  We basically
   # mill off the flat surface for each blade in
   # our standard cut depth incrments and then
   # mill off the next layer but skip any portion
   # of the blade that is above the new plane.
   # the intent is to minimize movment of the
   # bit in space where it isn't cutting anything
   #   #   #   #   #   #   #   #   #
   def mill_radial_fan(mill, shaft_diam, inside_diam,  outside_diam,   material_thick, num_blades, rim_thick)
   #   #   #   #   #   #   #   #   #
     tSpeed = mill.speed
     
     drill_through = 0 - (material_thick + 0.02)
     max_depth = drill_through - 0.05
     blade_to_air_space_ratio = 0.65
     space_between_blade = rim_thick + mill.bit_diam
       beg_diam   = inside_diam + mill.bit_diam
     lbeg_radius = beg_diam / 2
     lend_radius = (outside_diam / 2.0) - (rim_thick*2 +  mill.bit_radius)
     radius_delta = lend_radius - lbeg_radius
     num_bit_passes_in_radius = radius_delta / mill.cut_inc
     
     
     degrees_for_space_inner = degrees_for_distance(lbeg_radius, space_between_blade)     
     degrees_for_space_outer = degrees_for_distance(lend_radius, space_between_blade)
     
     fan_blade_total_space = (360.0 / num_blades.to_i)     
     usable_blade_space = fan_blade_total_space  - degrees_for_space_outer     
     fan_blade_width = usable_blade_space  *blade_to_air_space_ratio      
     fan_blade_air_space = usable_blade_space - fan_blade_width             
     degrees_delta = degrees_for_space_outer - degrees_for_space_inner     
     degrees_change_per_pass = (degrees_delta / num_bit_passes_in_radius).abs
     cutout_diam = (outer_radius * 2) + rim_thick + mill.bit_radisu
     
     print "(num_blades = ", num_blades, ")\n"
     print "(fan_blade_total_space =", fan_blade_total_space, ")\n"
     print "(degrees_for_space_outer=", degrees_for_space_outer, ")\n"
     print "(fan_blade_air_space=", fan_blade_air_space, ")\n"     
     print "(space between bladed inner = ", degrees_for_space_inner,")\n" 
     print "(space between blades outer=", degrees_for_space_outer, ")\n"   
     print "(degree_change_per_cut_inc=", degrees_change_per_pass, ")\n"
     print "(bit_radius=", mill.bit_radius, ")\n"
     print "(inner radius=", lbeg_radius,")\n"
     print "(outer radius=", lend_radius,")\n"
     print "(cut out radius=", cut_out_radius, ")\n"
     print "(drill_through = ", drill_through, ")\n"
     lcx = (outside_diam / 2) + mill.bit_diam + 0.02
     lcy = (outside_diam / 2) + mill.bit_diam + 0.02
     # move in by bit_diam to prevent cutting into vice
     mill.retract()          
     curr_depth = 0
     mill.retract() 
     mill.move_fast(lcx,lcy)
     mill.drill(lcx, lcy, curr_depth, drill_through/10) 
     mill.retract()      
     # Work around the wheel and mill out 
     # the fan blades
     fan_blade_beg = 0 
    
     
     while (( fan_blade_beg + fan_blade_total_space) <= 360)
       
       mill.retract()
       
       pass_cnt = 0       
       cmz = 0        
       mill.retract()
       max_depth = drill_through + mill.cut_depth_inc + 0.04
       
                                        
               
       # Mill the sloping down portin of
       # the blades Stoppoing 0.04 before
       # going thorugh
       cmz -= mill.cut_depth_inc
       while true               
         tdepth = 0
         curr_in_deg = fan_blade_beg
         curr_out_deg = fan_blade_beg
         step_cnt = 0
         curr_radius = lend_radius         
         while(true) 
           if ((max_depth - cmz).abs > mill.cut_depth_inc * 0.9)
              degree_per_step = 5.0
              #mill.set_speed(tSpeed)
           else
              degree_per_step = 1.0
              mill.set_speed(tSpeed / 2.0)
           end
                       
           pass_end_deg = (fan_blade_beg + fan_blade_width) 
                     
           # Mill the downward slope   
           # for the blade.                     
           changing_radius_curve(mill, lcx,lcy,
              beg_radius = curr_radius, 
              beg_degree = fan_blade_beg , 
              beg_z = 0 ,  
              end_radius = curr_radius, 
              end_degree = pass_end_deg, 
              end_z  =  cmz,  
              degrees_per_step=degree_per_step,           
              skip_z_LT= nil, 
              skip_z_GT = nil)      

              
           mill.set_speed(tSpeed * 4) 
            # comming back up so can
            #  go faster
           
           # Traceback for blade space
           changing_radius_curve(mill, lcx,lcy,
           beg_radius = curr_radius, 
           beg_degree = pass_end_deg , 
           beg_z = cmz ,  
           end_radius = curr_radius, 
           end_degree = fan_blade_beg, 
           end_z  =  -0.002 ,  
           degrees_per_step=degree_per_step,           
           skip_z_LT=  nil, 
           skip_z_GT = nil)
                    
           if (curr_radius == lbeg_radius)
             curr_radius = lend_radius
             break
           else
             print "(Curr Radius = ", curr_radius, ")\n"
             curr_radius  -= mill.cut_inc
             if (curr_radius  < lbeg_radius)
               print "(reset to beg_radius)"
               curr_radius = lbeg_radius
             end #if
           end # else
           
         end # while radius
         if (cmz == max_depth)
           break
         else
           cmz -= mill.cut_depth_inc
           if (cmz < max_depth)
             cmz = max_depth
           end
         end #else
        end #while depth
                          
        
       
       
       
       ###################################
       ### Mill out the flat air space
       ### between the blades
       ###################################
       
       pass_cnt = 0       
       cmz = 0        
       mill.retract()  
       while true       
         tdepth = 0
         curr_in_deg = fan_blade_beg
         curr_out_deg = fan_blade_beg
         step_cnt = 0
         curr_radius = lend_radius
         degree_per_step = 5
         max_depth = drill_through + mill.cut_depth_inc
         while(true) 
            
           # Based on the relative position of the
           # from inward to outward have to adjust
           # our ending_degree for to keep same
           # effective difference between blades
           # even though it increases the degrees
           # when the radius grows larger.
           curr_delta = lend_radius - curr_radius
           passes_in = curr_delta / mill.cut_inc
           degree_adjust = passes_in *          degrees_change_per_pass
           
           pass_beg_deg = fan_blade_beg + fan_blade_width
           pass_end_deg = (pass_beg_deg + fan_blade_air_space) - degree_adjust
           
           print "(curr_delta=", curr_delta, "  passes_in=", passes_in,  " degree_adjust=", degree_adjust, ")\n"
          

           # Mill the curve for the air flow    
           changing_radius_curve(mill, lcx,lcy,
              beg_radius = curr_radius, 
              beg_degree = pass_beg_deg , 
              beg_z = cmz ,  
              end_radius = curr_radius, 
              end_degree = pass_end_deg, 
              end_z  =  cmz - mill.cut_depth_inc / 2,  
              degrees_per_step=degree_per_step,           
              skip_z_LT= nil, 
              skip_z_GT = nil)               
         
              
           ###################
           # Trace back
           changing_radius_curve(mill, lcx,lcy,
             beg_radius = curr_radius, 
             beg_degree = pass_end_deg , 
             beg_z = cmz - mill.cut_depth_inc/2,  
             end_radius = curr_radius, 
             end_degree = pass_beg_deg, 
             end_z  =  cmz - mill.cut_depth_inc,  
             degrees_per_step=degree_per_step,           
             skip_z_LT=  nil, 
             skip_z_GT = nil)
                    
           if (curr_radius == lbeg_radius)
             curr_radius = lend_radius
             break
           else
             print "(Curr Radius = ", curr_radius, ")\n"
             curr_radius  -= mill.cut_inc
             if (curr_radius  < lbeg_radius)
               print "(reset to beg_radius)"
               curr_radius = lbeg_radius
             end #if
           end #else         
         end #while radius  
        if (cmz == max_depth)
          break
        else      
          cmz -= mill.cut_depth_inc
          if (cmz < max_depth)
            cmz = max_depth
          end
        end #else
       end  # while depth 
      
      
     
       fan_blade_beg += fan_blade_total_space
       fan_blade_end = fan_blade_beg + fan_blade_width
       mill.retract()
     end # while fan blades
        
     
     if (mill.bit_diam <= shaft_diam)
       mill.retract()
       mill.move(lcx, lcy)
       aCircle = CNCShapeCircle.new(mill) # this circle re-
       aCircle.beg_depth = curr_depth 
       aCircle.mill_pocket(lcx, lcy, shaft_diam, 
         curr_depth - drill_through ,  
         island_diam=0)
       mill.retract()  
     else
      print "(Could not finish center whole because bit is larger than needed thread)\n"
     end #if
    
    
  
          
    #aMill.pause("put 1/4 inch bit in re-center")
     print "(preparing to do final cutout)\n" 
     mill.retract(0.1)
     curr_cepth = 0
     mill.move_fast(lcx - cut_out_radius, lcy)
     spiral_down_circle(mill, lcx,lcy,
         cut_out_diam,
         curr_depth,
         drill_through,
         adjust_for_bit_radius = false,
         auto_speed_adjust = false)
     mill.retract()   
   end # method

     
   
   
########################
## Main porgram area
#######################
if (1 == 1)
  aMill = CNCMill.new()
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
   
   
  mill_radial_fan(aMill, 
    shaft_diam = 0.23, 
    inside_diam = 0.6,  
    outside_diam = 3.0,  
    material_thick = 0.25,
    num_blades = 3, 
    rim_thick  = 0.05)
end #if