module Pump_centrifuge_util
 
   def cavity_diam 
     return wheel_diam + (min_wheel_clearance * 2)
   end
   
   def cr1
     return cavity_diam / 2
   end
   
   
   def cr2
     return (cavity_diam + amount_lopside) / 2
   end
   
   def wheel_radius
     return @wheel_diam / 2
   end
   
   def curr_depth_sub(aNum)
     @curr_depth -= aNum
   end
   
   def curr_depth_add(aNum)
     @curr_depth += aNum
   end
   
   
   def vertical_space_used_non_wheel
     return floor_thick + bearing_thick + air_gap_at_bottom  + bottom_plate_thick + remove_surface_amt
   end
   
   def number_of_wheels
      return (vertical_space_used_non_wheel / plate_thick).to_i
   end
   
   def min_x
     return x_adj
   end
  
   # Need one bolt space between bolt and
   # edge of unit and another between bolt
   # and cavity and another set on the oposite
   # end 
   def max_x        
     return (lcx +  wheel_radius + min_wheel_clearance + diffuser_width + wall_thick  + bolt_space_from_edge +  volute_width_right)
   end
   
  
   
   def max_y
      #return min_y + max_circle_lop_size + (wall_thick*2) + (mount_bolts_diam*2) + (bolt_space_from_edge * 2)
      # + (min_wheel_clearance *2)
      return (lcy + wheel_radius + min_wheel_clearance  + diffuser_width + wall_thick + bolt_space_from_edge) 
   end
   
   def min_y
     return  y_adj   
   end
   
   
   
   def entrance_off_center_adj 
     return bearing_outside_diam / 2 +  aMill.bit_radius + wall_thick / 2
   end
   
   def drill_through_adj
     return 0.0005
   end
   
   def drill_through_depth
     return  0 - (@stock_z_len + drill_through_adj )
   end
      
   def aMill
     @mill
   end

   
   def hub_diam
     bearing_outside_diam + (wall_thick * 3)   
   end
   
   def bearing_mill_depth 
     return bearing_thick 
   end
   
   def  bearing_vert_exposed
     return  0
   end
   
   def  bottom_plate_vert_space 
     return  bottom_plate_thick + (bearing_vert_exposed) + air_gap_at_bottom
   end
   
   def max_lop_depth 
     0 - (wheel_thick - bottom_plate_thick)
   end
   
   def max_circle_lop_size 
     wheel_diam + amount_lopside
   end
   
   def max_circle_lop_radius 
     max_circle_lop_size / 2.0
   end
   
   def exit_pocket_arc_beg_radius  
     (wheel_diam / 2) - mill.bit_radius 
   end
   
   
   def aCircle
      return @tCircle
   end

   def hub_diam
     return  hub_diam
   end
   
   def hub_radius 
     return  hub_diam / 2.0
   end
   
   #  How large to make the hub diameter
   #  for the impeller.  The air entry
   #  area will not begin until the
   #  other side of this area.  If you
   #  mill staight down using this value
   #  you will get a correct circle size
   def impeller_hub_mill_diam
     return  hub_diam + mill.bit_diam + (hub_wall_thick * 2)
   end
   
   
   def impeller_hub_mill_radius
     return  impeller_hub_mill_diam / 2.0
   end
   
   # Cutout diam for the hub nut.  We need this
   # for twoo purposes.  The first is to actually
   # cut out the impeller nut.  The second is to 
   # is because we need ot mill hole to mate with
   # it.
   def impeller_hub_nut_mill_diam
      return air_entry_end_diam + (hub_wall_thick * 4) + mill.bit_diam + mill.bit_radius
   end 
   
   def impeller_hub_nut_mill_radius
      return impeller_hub_nut_mill_diam / 2.0
   end 
   
   def wheel_radius 
     wheel_diam / 2.0
   end
       
   def total_impeller_thick
      return (wheel_thick + wheel_lid_thick + wheel_wobble_room)
   end
   
   def air_entry_beg_radius
     hub_radius
   end
   
   def air_entry_beg_diam
     air_entry_beg_radius * 2.0
   end

   
   def air_entry_length
     al = (wheel_radius - hub_radius) / 3.0
     if (al  < mill.bit_diam)
       #print "(forcing minimum air space of 1 bit diam)\n"
       al = mill.bit_diam
     end     
     print "(air entry length=",al, ")\n"
     return al
   end
   
     
   def air_entry_end_radius     
     return hub_radius + air_entry_length
   end
   
   def air_entry_end_diam 
     return air_entry_end_radius * 2.0
   end
   
   
   def blade_depth
     if (@blade_depth == nil) && (stock_z_len != nil)
       @blade_depth = @stock_z_len * 0.85
       if ((@stock_z_len - @blade_depth).abs < min_blade_depth)
         @blade_depth = 0 - (@stock_z_len - min_blade_depth).abs
       end
     end     
     if (@blade_depth > 0)
       @blade_depth = 0 - @blade_depth
     end     
     return @blade_depth
   end
   
   
   def blade_depth=(aNum)     
     @blade_depth = aNum
   end
   
   def blade_height    
     return blade_depth
   end
 
   
   
   def min_blade_depth
     if material_type == "acrylic"
        return  0.07
     elsif material_type == "foam"
        return  0.3
     elsif material_type == "balsa"
        return  0.1
     else
        return 0.05  # Aluminum
     end #if
   end #
   
   def cutout_diam   
     cutout_diam  = wheel_diam + aMill.bit_diam
   end
   
   
   def cutout_radius
     return (cutout_diam / 2.0)
   end
   
   
   # return the number of degrees needed to
   # traverse a distance along circumfrenc
   # of a circle at specified radius using
   # the current bit.
   #  TODO: Transfer to mill
   def bit_deg_rad(radius)
      return degrees_for_distance(radius, mill.bit_diam)
   end #meth
   
   # return the number of degrees needed to
   # travers the bit diameter at the wheel
   # radius.  Used to calcualte number
   # of spokes or hole that can be fit
   # in a given sized wheel
   def bit_deg_impell
      return degrees_for_distance(wheel_radius, mill.bit_diam)
   end
   
  
   
   
   #   #   #   #   #   #   #   #   #
   # Horizontally mirror a point (X Axis)
   # based on current size specifications
   #   #   #   #   #   #   #   #   #
   def hmirror(pxin)
     return  max_x - pxin
   end
   
  
   #   #   #   #   #   #   #   #   #
   # Vertically  mirror a point  (Y Axis)
   # based on current size specifications
   #   #   #   #   #   #   #   #   #
   def vmirror(pyin)
     return  max_y  - pyin
   end
   
   
   
   
   
   
    #   #   #   #   #   #   #   #   #  
   def center_air_entry_arc_pockets(pCent_x, pCent_y, inner_diam, outer_diam,  num_pockets, pBeg_z,  pEnd_z, spike_width)
   #   #   #   #   #   #   #   #   #
    if (pEnd_z == nil)
     pEnd_z = 0 - stock_z_len
    end
    inner_radius = inner_diam / 2.0
    outer_radius = outer_diam / 2.0
    # Cut the rest of the way except for 4 spikes
     mill.retract()
     width_of_segment = 360 / num_pockets
     width_of_spike = degrees_for_distance(inner_radius, spike_width)
     width_of_pocket = width_of_segment - width_of_spike
     print "\n\n(CENTER AIR ENTRY ARC POCKETS)\n"
     print "(pBeg_z = ", pBeg_z, ")\n"
     print "(pEnd_z = ", pEnd_z, ")\n"
     print "(spike_width=", spike_width, ")\n" 
     print "(center_air_entry_arc_pockets)\n"
     print "(inner_radius=", inner_radius, ")\n"
     print "(outer_radius=", outer_radius, ")\n"
     print "(width_of_segment deg=", width_of_segment, ")\n"
     print "(width_of_spike deg =", width_of_spike, ")\n"
     print "(width_of_pocket deg=", width_of_pocket, ")\n"
     
     curr_degree = 0
     for pocket_num in 1..num_pockets
       mill.retract()       
       end_degree = curr_degree + width_of_pocket
       print "(end_degree=", end_degree, ")\n"
       arc_segment_pocket(
         mill, 
         pCent_x,
         pCent_y,
         inner_radius,
         outer_radius,  
         curr_degree,
         end_degree,  
         pBeg_z,
         pEnd_z,
         pDegree_inc = 1.0)
         
       curr_degree += width_of_segment        
       mill.retract()
     end #for segments
   end # method
      
  

   #  #  #  #  #  #  #  #  #  #  #  #  #  # 
   def mill_axel_normal(pBegZ, pEndZ)
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
       return mill_axel_common(lcx, lcy, pBegZ, pEndZ)
   end
    
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_axel_mirrored(pBegZ, pEndZ=nil)
       return mill_axel_common(lcx, vmirror(lcy), pBegZ, pEndZ)
    end #meth
    
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_axel_common(pcx, pcy, pBegZ, pEndZ=nil)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
      #  #  #  #  #  #  #  #  #  #  #  #  #  #
     if pEndZ == nil
       pEndZ = drill_through_depth
     end
   
     aMill.retract(pBegZ)
     aCircle.beg_depth = pBegZ
     aCircle.mill_pocket(pcx, pcy, shaft_diam, 
       pEndZ, 
       island_diam=0)   
     return pEndZ
    
    end #method mill_axel_common
  
    
     # The bearing socket is composed of 
     # three elements. 
     #  A) The slot containing
     #     the bearing,   
     #  B) The Hub or solid  material around 
     #     the bearing.
     # C)  The air gap area around the
     #     bearing.
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_bearing_socket(pBegZ=0, pEndZ=nil)
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
     return mill_bearing_socket_common(lcx, lcy, pBegZ, pEndZ)    
    end # meth
    
    
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_bearing_socket_mirrored(pBegZ=0, pEndZ=nil)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
      return mill_bearing_socket_common(lcx, vmirror(lcy), pBegZ, pEndZ)    
    end #meth
    
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_bearing_socket_common(pcx, pcy, pBegZ, pEndZ)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
     if (pBegZ > 0)
       pBegZ = 0 - pBegZ
     end
     if (pEndZ == nil)
       pEndZ = pBegZ - bearing_mill_depth
     end
     if (pEndZ > 0)
      pEndZ = 0 - pEndZ
     end
     
     aCircle.beg_depth = pBegZ
     aCircle.mill_pocket(pcx, pcy, 
       bearing_outside_diam, 
       pEndZ, 
       island_diam=0)   
     return pEndZ          
    end #meth
    
   
   
   
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   def mill_bolts_normal(pBegZ, pEndZ=nil)
   #  #  #  #  #  #  #  #  #  #  #  #  #  #   
      # --------------
     # -- ADD THE 4 Corner Mounting
     # -- holes
     # -------------         
   
     if (pEndZ == nil)
       pEndZ = 0 - bolt_depth.abs
     end
     
     mount_bolts_radius = mount_bolts_diam / 2
     
     bolt_edge_adj = bolt_space_from_edge + mount_bolts_radius
     
     

     aMill.retract(0.2)
     aMill.move_fast(min_x + bolt_edge_adj, min_y + bolt_edge_adj)
     aCircle.beg_depth = pBegZ    
     aCircle.mill_pocket(
       min_x + bolt_edge_adj,
       min_y + bolt_edge_adj, 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0) 
       
     
     aMill.retract()   
     aCircle.mill_pocket(
       min_x + bolt_edge_adj,
       max_y - bolt_edge_adj, 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0) 
       
          
     aMill.retract()     
     aCircle.mill_pocket(
       max_x - bolt_edge_adj,
       max_y - bolt_edge_adj, 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0) 
            
 
     aMill.retract()      
     aCircle.mill_pocket(
       max_x - bolt_edge_adj,
       min_y + bolt_edge_adj, 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0)        
       
     aMill.retract() 
    
    end #meth
    
    
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_bolts_mirrored(pBegZ=0, pEndZ=nil)
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
      # --------------
     # -- ADD THE 4 Corner Mounting
     # -- holes
     # -------------         
    if (pEndZ == nil)
       pEndZ = 0 - bolt_depth.abs
     end
     
     mount_bolts_radius = mount_bolts_diam / 2
     bolt_edge_adj = bolt_space_from_edge + mount_bolts_radius

          
     aMill.retract(0.2)
     aMill.move_fast(min_x + bolt_edge_adj, vmirror(min_y + bolt_edge_adj))
     aCircle.beg_depth = pBegZ    
     aCircle.mill_pocket(
       min_x + bolt_edge_adj,
       vmirror(min_y + bolt_edge_adj), 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0) 
       
     
     aMill.retract()   
     aCircle.mill_pocket(
       min_x + bolt_edge_adj,
       vmirror(max_y - bolt_edge_adj), 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0) 
       
          
     aMill.retract()     
     aCircle.mill_pocket(
       max_x - bolt_edge_adj,
       vmirror(max_y - bolt_edge_adj), 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0) 
            
 
     aMill.retract()      
     aCircle.mill_pocket(
       max_x - bolt_edge_adj,
       vmirror(min_y + bolt_edge_adj), 
       mount_bolts_diam, 
       pEndZ, 
       island_diam=0)        
       
     aMill.retract() 
    
    end # meth
    
    
    
    
    
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_impeller_outline_normal(pBegZ=0, pEndZ=nil)
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
      return  mill_impeller_outline_common(lcx, lcy, pBegZ, pEndZ)    
    end # meth
    
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_impeller_outline_mirrored(pBegZ, pEndZ)
      #  #  #  #  #  #  #  #  #  #  #  #  #  #
      return mill_impeller_outline_common(lcx, vmirror(lcy), pBegZ, pEndZ)    
    end # meth
    
     
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_impeller_outline_common(pcx, pcy, pBegZ=0, pEndZ=nil)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #  
     if (pEndZ == nil)
       pEndZ = pBegZ - drill_through_depth.abs
     end  
     if (pBegZ > 0)
       pBegZ = 0 - pBegZ
     end
     if (pEndZ > 0)
       pEndZ = 0 - pEndZ
     end
     
     aMill.retract(pBegZ) 
     aCircle.beg_depth = pBegZ
     aCircle.mill_pocket(pcx, pcy, 
       cavity_diam, 
       pEndZ, 
       island_diam=hub_diam)  
     aMill.retract(pBegZ)  
     return pEndZ         
    end # meth

        
    # TODO:  Have to be able to start the lopsided circle
    #   with an island in the center. 
    #   so allow space for diffuser.
    #   Have to allow space for diffuser around the edge
    #   right next to the wheel.
    
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_volute(pBegZ, pEndZ, pFloorThick = 0)
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
      tmp_end_z = pEndZ + pFloorThick.abs
      aMill.retract() 
      # Mill out the expanding volute section
      arc_segment_pocket(
            mill, 
         pCirc_x = lcx,
         pCirc_y = lcy,
         pBeg_radius = exit_pocket_arc_beg_radius ,
         pEnd_radius = max_circle_lop_radius + mill.bit_diam,
         pBeg_angle  = exit_pocket_arc_beg_deg,
         pEnd_angle  = exit_pocket_arc_end_deg,  
         pBeg_z      = pBegZ,
         pEnd_z      = tmp_end_z,         
         pDegree_inc = 1.0)

      # The part that goes all the 
      # way through.
      arc_segment_pocket(
        mill, 
         pCirc_x = lcx,
         pCirc_y = lcy,
         pBeg_radius = max_circle_lop_radius ,
         pEnd_radius = max_circle_lop_radius + volute_len,
         pBeg_angle  = exit_pocket_arc_beg_deg,
         pEnd_angle  = exit_pocket_arc_end_deg,  
         pBeg_z      = pBegZ,
         pEnd_z      = pEndZ,         
         pDegree_inc = 1.0)
        
      aMill.retract() 
    end # meth

    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_volute_mirrored(pBegZ, pEndZ, pFloorThick = 0)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
      aMill.retract() 
      tmp_end_z = pEndZ + pFloorThick.abs
            
      arc_segment_pocket(
            mill, 
         pCirc_x = lcx,
         pCirc_y = vmirror(lcy),
         pBeg_radius = exit_pocket_arc_beg_radius ,
         pEnd_radius = max_circle_lop_radius + mill.bit_diam,
         pBeg_angle  = 180 + exit_pocket_arc_beg_deg,
         pEnd_angle  = 180 + exit_pocket_arc_end_deg,  
         pBeg_z      = pBegZ,
         pEnd_z      = tmp_end_z,         
         pDegree_inc = 1.0)
    
      arc_segment_pocket(
            mill, 
         pCirc_x = lcx,
         pCirc_y = vmirror(lcy),
         pBeg_radius = exit_pocket_arc_beg_radius ,
         pEnd_radius = max_circle_lop_radius + volute_len,
         pBeg_angle  = 180 + exit_pocket_arc_beg_deg,
         pEnd_angle  = 180 + exit_pocket_arc_end_deg,  
         pBeg_z      = pBegZ,
         pEnd_z      = pEndZ,         
         pDegree_inc = 1.0)
    
           
      aMill.retract()   
    end # meth

        
    
    # TODO:  Have to be able to start the lopsided circle
    #   with an island in the center. 
    #   so allow space for diffuser.
    #   Have to allow space for diffuser around the edge
    #   right next to the wheel.
    
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_impeller_and_volute_outline(pBegZ, pEndZ, pFloorThick = 0)
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
      tmp_end_z = pEndZ + pFloorThick.abs
      aMill.retract() 
      mill_volute(pBegZ, pEndZ, pFloorThick)
      aMill.retract() 
      mill_lopsided_circle(aMill, lcx, lcy, wheel_diam, max_circle_lop_size,
        exit_pocket_arc_beg_deg,
        (360 + exit_pocket_arc_end_deg) - mill.degrees_for_bit_diam(max_circle_lop_size),
        pBegZ,tmp_end_z)
      aMill.retract() 
    end # meth
    
    
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_impeller_and_volute_outline_mirrored(pBegZ, pEndZ, pFloorThick = 0)
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
      aMill.retract() 
      tmp_end_z = pEndZ + pFloorThick.abs
      mill_volute_mirrored(pBegZ, pEndZ, pFloorThick)      
      aMill.retract()   
      mill_lopsided_circle(aMill, lcx, vmirror(lcy), wheel_diam, max_circle_lop_size, 180 + exit_pocket_arc_beg_deg, 
        180 + 360 + exit_pocket_arc_end_deg,pBegZ,pEndZ)
      aMill.retract() 
    end # meth
    
    
    
   
    
   
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_cut_off_normal(pBegZ=0, pEndZ=nil)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
     if (pBegZ == nil)
       pBegZ = 0 
     end
     if (pEndZ == nil)
         pEndZ = pBegZ - drill_through_depth
     end
     
     mill_layered_rectangle_outline(mill, min_x,min_y,pBegZ,max_x, max_y, pEndZ, round_corner_radius=0.25, adjust_type="out")
     
    end # meth
    
    
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_cut_off_mirred(pBegZ=nil, pEndZ=nil)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
     if (pBegZ == nil)
       pBegZ = 0 - remove_surface_amt
     end
     if (pEndZ == nil)
         pEndZ = pBegZ - (drill_through_depth * 0.95)
     end
     
     
     mill_layered_rectangle_outline(mill, min_x,vmirror(min_y),pBegZ,max_x, vmirror(max_y), pEndZ, round_corner_radius=0.25, adjust_type="out")
     
       
      return pEndZ
    end # meth
    
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def remove_surface(pBegZ=0, pEndZ=nil)   
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
      # Mill off the surface to make sure we get a smooth
      # seal Mill out exit area 
      # where the outlet hole
      # will be drilled          
      if (pEndZ == nil)
         pEndZ = pBegZ - remove_surface_amt
      end
      aMill.retract(pBegZ)
      aRect =  CNCShapeRect.new(aMill,
        0, 
        0 - aMill.bit_radius / 2, 
        max_x + aMill.bit_radius/2, 
        stock_x_len + aMill.bit_radius/2,
        pEndZ)
      aRect.beg_depth = pBegZ        
      aRect.skip_finish_cut()
      aRect.do_mill()
      aMill.retract(pBegZ)
      return pEndZ
     end # meth
     
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def remove_surface_mirrored(pBegZ=0, pEndZ=nil)   
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
      # Mill off the surface to make sure we get a smooth
      # seal Mill out exit area 
      # where the outlet hole
      # will be drilled     
      if (pEndZ == nil)
         pEndZ = pBegZ - remove_surface_amt
      end
      aRect =  CNCShapeRect.new(aMill,
        0, 
        vmirror(0 - aMill.bit_radius / 2), 
        max_x + aMill.bit_radius/2, 
        vmirror(stock_x_len + aMill.bit_radius/2),
        pEndZ)
      aRect.beg_depth = pBegZ        
      aRect.skip_finish_cut()
      aRect.do_mill()
      aMill.retract()
      return pEndZ
     end # meth
     
    #  #  #  #  #  #  #  #  #  #  #  #  #  #     
    def mill_volute_sized_circle(pBegZ=nil, pEndZ=nil)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
       return mill_volute_sized_circle_common(lcx, lcy, pBegZ, pEndZ)
    end #meth
     
    #  #  #  #  #  #  #  #  #  #  #  #  #  #     
    def mill_volute_sized_circle_mirrored(pBegZ, pEndZ)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
      mill_volute_sized_circle_common(lcx, vmirror(lcy), pBegZ, pEndZ)
    end #meth
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #     
    def mill_volute_sized_circle_common(pcx, pcy, pBegZ=0, pEndZ=nil)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
     if (pEndZ == nil)
       pEndZ = pBegZ - wheel_thick
     end  
     mill.retract(pBegZ)
     aCircle.beg_depth = pBegZ
     aCircle.mill_pocket(pcx, pcy, 
       max_circle_lop_size, 
       pEndZ, 
       island_diam=hub_diam)   
     mill.retract(pBegZ)
     return pEndZ 
    end #meth
    
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def chamfer_corners(pBegZ, pEndZ)
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    end
    
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def chamfer_corners_mirrored(pBegZ, pEndZ)
     #  #  #  #  #  #  #  #  #  #  #  #  #  #
    end

       
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   def cut_out_impeller(pCent_x, pCent_y)
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   
     cut_out_cir_nub(pCent_x, pCent_y, cutout_diam, 0, drill_through_depth)
   end
   
    
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   # Cuts a circle out at the specified diam
   # leaving small nubs in place to keep the wheel
   # attached to the stock but easy to remove after
   # the fact.
   #  #  #  #  #  #  #  #  #  #  #  #  #  #    
   def cut_out_circ_nub(pCent_x, pCent_y, pDiam=nil, pBegZ=0, pEndZ=nil)
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
       pBegZ = 0 - pBegZ.abs
       if (pEndZ == nil)
         pEndZ = drill_through_depth
       end
       pEndZ = 0 - pEndZ.abs       
       if (pDiam == nil)
         pDiam = cutout_diam
       end
       pRadius    = pDiam / 2.0
       trim_depth = (pEndZ + nub_thick + drill_through_adj)
       deg_for_nub  = degrees_for_distance(pRadius, nub_width + mill.bit_diam)    
       width_of_segment = 360.0 / nub_num    
       width_mill_area = width_of_segment - deg_for_nub    
       print "(deg for nub=", deg_for_nub, ")\n"
       
       # mill cutout of edge almost all the
       # way through.
       print "(preparing to do final cutout)\n" 
       curr_cepth = 0
       mill.retract(0.3)      
       
       cp = calc_point_from_angle(
                  pCent_x, pCent_y ,
                  360,
                  pDiam / 2.0)
       mill.move(cp.x,cp.y)
         
       spiral_down_circle(
         mill   = aMill, 
         x      =  pCent_x,
         y      =  pCent_y, 
         diam   = pDiam, 
         beg_z  = pBegZ, 
         end_z  = trim_depth, 
         adjust_for_bit_radius = false, 
         outside               = true, 
         auto_speed_adjust     = false)  
      
     curr_depth = trim_depth
     mill.retract()
      
   
     # Cut the rest of the way except for 
     # the nubs or spikes     
 
     beg_degree = 0
     while (true) 
       curr_depth -= mill.cut_depth_inc
       next_depth = curr_depth - mill.cut_depth_inc
       if (next_depth < pEndZ)
         next_depth = pEndZ
       end
       if (curr_depth < pEndZ)
         curr_depth = pEndZ        
       end
       
       for spik_num in 1..nub_num
         end_degree = beg_degree + width_of_segment
         mill_end_degree = beg_degree + width_mill_area
         mill.retract(trim_depth)  
         # Mill the lower part     
         changing_radius_curve(mill, 
           pCent_x,pCent_y,
           pRadius, 
           beg_degree,  
           curr_depth,  
           pRadius, 
           mill_end_degree,
           next_depth,  
           pDegrees_per_step=1.0, 
           pSkip_z_LT=nil, 
           pSkip_z_GT=nil, 
           pAuto_speed_adjust=false)
           
         mill.retract(trim_depth)   
         # move over the nub we do it this
         # way to keep moving in the point 
         # of curve so we don't have to
         # retract all the way to get over
         # the nubs.  This produces more code
         # but less wasted motion.
         changing_radius_curve(mill, 
           pCent_x,pCent_y,
           pRadius, 
           mill_end_degree,  
           trim_depth,  
           pRadius, 
           end_degree,
           trim_depth,  
           pDegrees_per_step=1.0, 
           pSkip_z_LT=nil, 
           pSkip_z_GT=nil, 
           pAuto_speed_adjust=false)
           
         beg_degree += width_of_segment        
       end #for segments
      
       if (curr_depth == pEndZ)
         break
       end
     end #while depth
     mill.retract()       
   end


end #module
