module Pump_centrifuge_body



   #   #   #   #   #   #   #   #   #
   #  Bearing Holder.   This item is separated
   #  from the rest of the layers and can be 
   #  winched down for a tight on the bearing
   #  by moving a couple of spacer bolts.
   #  This allows a single axel to accomodate
   #  a few platters without critical measure.
   #  In a completed assembled unit the bearing
   #  holder could be integrated into the top plate
   #  but it would require close tolerances so that 
   #  when clamped down it would provide proper pressure
   #  from bearing to bearing.
   #   #   #   #   #   #   #   #   #
   def mill_top_bearing_holder(pBegZ=0, pEndZ=nil)
   #   #   #   #   #   #   #   #   #
      print "(pump_centrifuge top bearing holder)\n"
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
     
     
     curr_depth = 0       
     cut_through = pEndZ
     air_gap = 0 - (floor_thick * 2)
     if (air_gap > stock_z_len * 0.7)
       air_gap = stock_z_len * 0.7
     end
     
     mill.retract()          
     #print "(air_gap=", air_gap, ")\n"
     
     
     
      beg_x = min_x + edge_adjust
      beg_y = min_y + edge_adjust
      rec_x_len = (max_x - min_x) - (edge_adjust * 2)
      rec_y_len = (max_y - min_y) -(edge_adjust * 2) 
      
      aRect =  CNCShapeRect.new(aMill,
        beg_x, 
        beg_y, 
        rec_x_len, 
        rec_y_len,
        air_gap)
        
      aRect.beg_depth = 0        
      aRect.skip_finish_cut()
      aRect.do_mill()
      aMill.retract(0)
    
     aMill.retract() 
       aCircle.beg_depth = 0
       aCircle.mill_pocket(pcx, pcy, 
         diffuser_end_diam + mill.bit_diam, 
         pEndZ, 
         island_diam=hub_diam)  
       aMill.retract(pBegZ)  
     
     curr_depth = air_gap
     
    # Mill the shaft slot.
     mill.retract()
     print "\n\n(BEARING SOCKET)\n"
     curr_depth = mill_bearing_socket_mirrored(curr_depth)
     mill.retract()
     print "\n\n(AXEL HOLE)\n"
     mill_axel_mirrored(curr_depth)
     mill.retract()
    
     
     
     # Mill the entrance as far away from motor
     # as possible and still be inside volute sized
     # area      
     # Position relative to the
     # rectangle
     print "\n\n(MAIN AIR INLET HOLE)\n"
     #print "(max_x = ", max_x, ")\n"
     #print "(max_y = ", max_y, ")\n"
     mill.retract()
     far_x = max_x - (edge_adjust + entrance_diam)    
     far_y = max_y - (edge_adjust + entrance_diam)
     enx = edge_adjust + entrance_diam
     #print "(far_x = ", far_x, ")\n"
     #print "(far_y = ", far_y, ")\n"
     aCircle.beg_depth = air_gap
     aCircle.mill_pocket(enx, vmirror(far_y), 
       entrance_diam, 
       drill_through_depth, 
       island_diam=0)   

     print "\n\n(MOUNTING BOLTS)\n"
     mill.retract()
     mill_bolts_mirrored(pBegZ, pEndZ)
     mill.retract()
     print "\n\n(Chamfer corners)\n"
     chamfer_corners_mirrored(pBegZ, pEndZ)
          
     mill.retract()     
     print "\n\n(CUT OUT)\n"    
      
      mill.retract()
     
       mill_cut_off_mirred(pBegZ, pEndZ)
     
     mill.home()
   end # mill_lid method
   
   
   
   
   
   #   #   #   #   #   #   #   #   #
   # There are two lids.  One which 
   #   is the verry outside and 
   #   contains the hole to be 
   #   threaded for the inlet pipe
   #   the bearing slot and a cavity
   #   for directing the air to the 
   #   center.   
   #
   #   and the bearing slot
   #   this one acts only as a folding
   #   feed of the air to the center
   #   holes required by the centrifugical
   #   impeller.   The shaft axel must
   #   pass through this one and on to
   #   the motor so the inlet hole has
   #   offset from the axel and the
   #   motor size. 
   # 
   #   TODO:  If the inlet hole interferes
   #    with the motor size the this one
   #    should be thick enough to allow
   #    side entry of the air.
   #
   # This lid has to be the mirror
   # of the top.  I assume we will
   # flip on the Y axis so we mirror
   # only that axis -  Alternatively I 
   # could make it exactly the same
   # as the top but then we would
   # not have the bearing holder.
   
     # TODO: 
     # Inlets are in the lid at the top 
     # because the next layer is the 
     # next stage of compression.      
     # In the center around the bearing support
     # area there is an air space and then a 
     # ring wall which is close enough to the
     # bottom of the plate to act as a secondary
     # seal or inhibitor for the returning air 
     # flow.
     #
     # Note:  Getting the holes where we can
     # easily allow a pipe fitting around the 
     # motor is impossible so we use a two
     # layer lid.  The first layer is simply
     # a flat sheet with a threadable point to
     # connect the pipe and the bearing
     # slot.    The second layer
     # has the holes for the inlet
     # and axel shaft and cavity to allow
     # the air to move to the holes.  
     #
     #    
     # TODO:  The main issue with getting the
     #  wheels properly positioning on the 
     #  axel is getting the stops in the right
     #  location and then still being able to
     #  get the next wheel on.  Joe purchased
     #  some small spring clips that can be inserted
     #  into a groove which will keep the wheels 
     #  accurately positioned.   To balance out
     #  the axel with the D shapes we should have
     #  flat part of the axel on opposite sides
     #  of each layer.  
     #  
     #  In order to make fabrication
     #  as easy as possible we want each single
     #  layer to be enough thicker than the
     #  wheel it contains so that we have a small
     #  clearance and room for the floor.  Alternatively
     #  we could use all a single layer and 
     #  and then use a interveening layer which 
     #  is milled out to allow only the air space
     #  for the next layer.  The final alternative
     #  would be to mill both sides but that 
     #  requires perfect re-alignment after turning
     #  which would be difficult.   A better option
     #  would be to use a thinner slice which is 
     #  only thick enough to allow spinning space
     #  and a floor.
     
     
     # The bottom of the plate will be facing down
     # with the glued on top.  It needs a small 
     # space between it and the bearing support
     # if include bearing is true then a bearing
     # holder will be milled.  Otherwise a shaft
     # of the size of the shaft
     
   #   #   #   #   #   #   #   #   #
   def mill_lid_outer(pBegZ=0, pEndZ=nil, include_bearing=false, shaft_size=0.25)
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
     
     
     curr_depth = 0       
     cut_through = pEndZ
     air_gap = 0 - (floor_thick * 2)
     if (air_gap > stock_z_len * 0.7)
       air_gap = stock_z_len * 0.7
     end
     
     mill.retract()          
     #print "(air_gap=", air_gap, ")\n"
     #print "(lid_thick=", lid_thick, ")\n"
     #print "(cut_through depth=", cut_through, ")\n"
     # curr_depth = mill_volute_sized_circle_mirrored(curr_depth, air_gap)
     
      # by using the rectangle instead of
      # circle I can move the inlet further
      # away from the motor. 
      
      
      # TODO:  CHANGE THIS TO A VOLUTE TO MATCH
      #   THE REST OF THE PLATES.   MAY WANT A 
      #   CIRCLE TO MATCH THE ONE on the Separation
      #   plate
      
      print "(RECTANGULAR AIR CAVITY)\n"
     
      edge_adjust = wall_thick + mount_bolts_diam + bolt_space_from_edge  
          
      beg_x = min_x + edge_adjust
      beg_y = min_y + edge_adjust
      rec_x_len = (max_x - min_x) - (edge_adjust * 2)
      rec_y_len = (max_y - min_y) -(edge_adjust * 2) 
      
      aRect =  CNCShapeRect.new(aMill,
        beg_x, 
        beg_y, 
        rec_x_len, 
        rec_y_len,
        air_gap)
        
      aRect.beg_depth = 0        
      aRect.skip_finish_cut()
      aRect.do_mill()
      aMill.retract(0)
    
      
     
     curr_depth = air_gap
     
    # Mill the shaft slot.
     mill.retract()
     print "\n\n(BEARING SOCKET)\n"
     curr_depth = mill_bearing_socket_mirrored(curr_depth)
     mill.retract()
     print "\n\n(AXEL HOLE)\n"
     mill_axel_mirrored(curr_depth)
     mill.retract()
    
     
     
     # Mill the entrance as far away from motor
     # as possible and still be inside volute sized
     # area      
     # Position relative to the
     # rectangle
     print "\n\n(MAIN AIR INLET HOLE)\n"
     #print "(max_x = ", max_x, ")\n"
     #print "(max_y = ", max_y, ")\n"
     mill.retract()
     far_x = max_x - (edge_adjust + entrance_diam)    
     far_y = max_y - (edge_adjust + entrance_diam)
     enx = edge_adjust + entrance_diam
     #print "(far_x = ", far_x, ")\n"
     #print "(far_y = ", far_y, ")\n"
     aCircle.beg_depth = air_gap
     aCircle.mill_pocket(enx, vmirror(far_y), 
       entrance_diam, 
       drill_through_depth, 
       island_diam=0)   

     print "\n\n(MOUNTING BOLTS)\n"
     mill.retract()
     mill_bolts_mirrored(pBegZ, pEndZ)
     mill.retract()
     print "\n\n(Chamfer corners)\n"
     chamfer_corners_mirrored(pBegZ, pEndZ)
          
     mill.retract()     
     print "\n\n(CUT OUT)\n"    
      
      mill.retract()
     
       mill_cut_off_mirred(pBegZ, pEndZ)
     
     mill.home()
   end # mill_lid method
\
    

    
   #   #   #   #   #   #   #   #   #
   #   Main body area of the centrifuge pump
   #   An increasing diameter area with a volute
   #   of an increasing diameter volute.
   #   The entire case has the inlet with the 
   #   increasing area and a smaller diameter whole
   #   where the base of the blade goes that is supposed
   #   to act as a seal between the main area and the
   #   exit area.   When using plastic material we 
   #   use a slided strategy where the main body is
   #   the same diameter as the volute top and
   #   bottom are composed out of additional sheets.
   #   In any case volute has an exit to the next 
   #   layer.   The layer in between the volute and 
   #   the channels the air back to center where the
   #   next stage can accelerate it even more.
   #
   #
   #   In a real implementation we would actually 
   #   use increasing sizes of blades in each subsequent
   #   stage to increase the edge of wheel velocity from
   #   stage to stage.   The formula use the perimiter
   #   of the circle so 2*PI*R so the following
   #   measurements yield different speeds.
   #       1"  =  3.14
   #      1.5" =  4.71
   #      2.0" =  6.28
   #      4.0" = 12.56
   #
   #   The air exit velocity and hence the pressure
   #   is a direct relationship to the the RPM and 
   #   the speed at which the periphery of the wheel
   #   is spinning.   
   #
   #   TODO:  Figure out how to add the difusters
   #    
   #   #   #   #   #   #   #   #   #
   def mill_body(pBegZ = 0,  pEndZ = nil)
   #   #   #   #   #   #   #   #   #    
     if (pEndZ == nil)
       pEndZ = pBegZ -  stock_z_len
     end
     if (pBegZ > 0)
       pBegZ = 0 - pBegZ
     end
     if (pEndZ > 0)
       pEndZ = 0 - pEndZ
     end
     
     curr_depth = pBegZ       
     
     mill.retract()          
     # Body must leave wall_thick
     # at bottom of the impeller cavity. but 
     # be open at the volute to properly route
     # air into the next cavity.     
     mill_impeller_and_volute_outline(pBegZ, pEndZ, floor_thick) 
    
     mill.retract()
     print "\n\n(AXEL HOLE)\n"
     mill_axel_normal(pEndZ + floor_thick, pEndZ)
     mill.retract()
     
     mill.retract()          
     mill_bolts_normal(pBegZ, pEndZ)
     mill.retract()          
     chamfer_corners(pBegZ, pEndZ)
     mill.retract()          
     mill_cut_off_normal(pBegZ, pEndZ * 0.95)
     aMill.retract()
     aMill.home()
   end  # mill_body # 
      
   
   
     #   #   #   #   #   #   #   #   #
   #   The body separator allows a thicker
   #   wheel to be used by providing a 
   #   volute area with no bottom.
   #
   #   TODO:  Figure out how to add the difusters
   #    
   #   #   #   #   #   #   #   #   #
   def mill_body_separator(pBegZ = 0,  pEndZ = nil)
   #   #   #   #   #   #   #   #   #    
     if (pEndZ == nil)
       pEndZ = drill_through_depth
     end
     if (pBegZ > 0)
       pBegZ = 0 - pBegZ
     end
     if (pEndZ > 0)
       pEndZ = 0 - pEndZ
     end
     
     curr_depth = pBegZ       
     
     mill.retract()          
     # Body must leave wall_thick
     # at bottom of the impeller cavity. but 
     # be open at the volute to properly route
     # air into the next cavity.     
     mill_impeller_and_volute_outline(pBegZ, pEndZ, 0) 
        
     mill.retract()          
     mill_bolts_normal(pBegZ, pEndZ)
     mill.retract()          
     chamfer_corners(pBegZ, pEndZ)
     mill.retract()          
     mill_cut_off_normal(pBegZ, pEndZ * 0.95)
     aMill.retract()
     aMill.home()
   end  # mill_body # 
  
   
   
   
   # Layer Separator 
   # The inner lid is simply a separator
   # main impeller the outer lid.  It's
   # inlet holes are in the center 
   # where the centrifugical plade needs
   # them and it has a small air gap
   # area shapped to allow the air
   # to move from the periphery to
   # the center.   The same design
   # is used as the separator
   # between stages.  
   #
   # The bottom of the impeller will be 
     # facing up so that the air enters it's
     # center.  The solid part of the impeller 
     # is nestled in a tighly fitting area where
     # which helps seal against leaking.
     # The close tolerance between the flat
     # part of the impeller and the top of the
     # cavity also helps reduce leaking. 
     # This gives us a relatively
     # large barrier surface to prevent this kind of
     # leakage.   
     #
     #  On larger wheels we could have two or
     #  three sets of rings here that could provide 
     #  a better tourture path to reduce air leakag
     #  but this is most likely a mute issue
     #  since we will get some adhesion acceleration
     #  anyway which may create a sufficient amount of
     #  acceleration to create a positive pressure
     
   #  DEFER:  to make this layer efficient
   #   sunken ring the size of the batton 
   #   plate of the wheel acts as Seal #1
   #   Then we need a air space in the center
   #   with another ring as the primary 
   #   seal.   These two together are intended
   #   to prevent the higher pressure air at
   #   the edges from circling around and
   #   re-entering the center.   We want them
   #   to be as close as possible without actually
   #   requiring a formal wiper seal or oil.
   #   Each stage is only marginally higher 
   #   pressure than the next stage so we 
   #   hopefully it will prevent too much 
   #   reverse leakage.   On the flip side 
   #   we have a circular area that acts as
   #   the funnel from the prior layer to
   #   the center area.  It is important
   #   to mill the downward facing side first
   #   because the upward facing portion is
   #   less critical if it is off just a bit.
   # 
   #
   #  TODO: Joe use a circular tesla valvular
   #  conduit in the separating conduit to 
   #  to encourage air to move only in the
   #  direction of the compression and to
   #  minimize back pressure  
   #
   #  # TODO:  The main issue with getting the
     #  wheels properly positioning on the 
     #  axel is getting the stops in the right
     #  location and then still being able to
     #  get the next wheel on.  Joe purchased
     #  some small spring clips that can be inserted
     #  into a groove which will keep the wheels 
     #  accurately positioned.   To balance out
     #  the axel with the D shapes we should have
     #  flat part of the axel on opposite sides
     #  of each layer.  
     #  
     #  In order to make fabrication
     #  as easy as possible we want each single
     #  layer to be enough thicker than the
     #  wheel it contains so that we have a small
     #  clearance and room for the floor.   to 
     #  accomplish this a portino of the wheel is
     #  nestled in the air seal of the next
     #  layer up which effectively make the wheel
     #  that much shorter.

   #   #   #   #   #   #   #   #   #
   def mill_layer_separator(pBegZ=0, pEndZ=nil)
   #   #   #   #   #   #   #   #   #
    if (pEndZ == nil)
      pEndZ = 0 - stock_z_len
    end      

    
    print "\n\n(NESTED AREA for bottom of wheel)\n"   
    curr_depth = 0  
    aMill.retract()  
     aCircle.beg_depth = curr_depth
         
     net_depth = (pEndZ - pBegZ).abs
     # Technically we should never need
     # this cavity deeper than floor thick
     # but making it double deep leaves us
     # a little margine if wheel wobles.
     air_mix_depth = floor_thick * 2
     pbot = curr_depth - air_mix_depth;
     if (air_mix_depth > lid_thick * 0.60)
       air_mix_depth = lid_thick * 0.60
     end
      
     aCircle.mill_pocket(lcx, vmirror(lcy), 
       wheel_diam + min_wheel_clearance, 
       pbot,
       island_diam = 0)
     curr_depth = pbot
     
     # now we need the area to allow the inlet air to 
     # mix after coming through the holes.
     print "\n\n(Air Mixing Area at bottom of wheel)\n"
     aCircle.beg_depth = curr_depth
     pbot = curr_depth - (air_mix_depth * 0.2);
     
     aCircle.mill_pocket(lcx, vmirror(lcy), 
       air_entry_end_diam, 
       pEndZ,
      pbot)
     curr_depth = pbot
   
    
    #### Mill the exit air pockets to
    #### accept air from oposite side.   
    print "\n\n(AIR ENTRY arc segments)\n"
    center_air_entry_arc_pockets(
       pCent_x = lcx, 
       pCent_y = vmirror(lcy), 
       inner_diam = hub_diam, 
       outer_diam = air_entry_end_diam,  
       num_pockets = 4, 
       beg_z = curr_depth,  
       end_z = pEndZ, 
       spike_width = wall_thick)
    
       
     print "\n\n(AXEL HOLE)\n"
      mill_axel_mirrored(curr_depth)
      mill.retract()
     
      
     print "\n\n(MOUNTING BOLTS)\n"
     mill.retract()
     mill_bolts_mirrored(pBegZ, pEndZ)
     mill.retract()
     print "\n\n(Chamfer corners)\n"
     chamfer_corners_mirrored(pBegZ, pEndZ)
          
     mill.retract()     
     print "\n\n(CUT OUT)\n"    
     
     cod = 0 - ((pEndZ - pBegZ) * 0.8).abs      
     mill_cut_off_mirred(pBegZ, cod) 
       # only cut partially off to give
       # clamping surface.

       
     #---------------------
     #---- mill the oposite side
     #---------------------     
     # flip over the
     # connecting plate and route out the basic cavity.
     # Otherwise there will be no way for the air to make
     # it all the way through to the center entrance plate.
     # Make the air gap areas on the one side so they total
     # 50% and the one on the other side to toal 25% so 
     # we have 25% left over.
   
     mill.retract()
     mill.move(lcx,lcy)
     mill.plung(0.03) # make bit close to surface 
                      # to ease alignment.
     print "(bit should be directly centered over axel whole)\n"
     mill.pause("Flip unit over on the X Axis")

     # For this side we only use a single floor
     # thickness to avoid issues drilling 
     # all the way through.
     air_mix_depth = floor_thick
     if (air_mix_depth > lid_thick * 0.30)
       air_mix_depth = lid_thick * 0.30
     end
     air_depth_entrance = pBegZ - air_mix_depth.abs
           
     # Extended volute from largest area
     # down to the hub
     arc_segment_pocket(
            mill, 
         pCirc_x = lcx,
         pCirc_y = lcy,
         pBeg_radius = hub_radius  ,
         pEnd_radius = max_circle_lop_radius + volute_len,
         pBeg_angle  = exit_pocket_arc_beg_deg,
         pEnd_angle  = exit_pocket_arc_end_deg,  
         pBeg_z      = pBegZ,
         pEnd_z      = air_depth_entrance,         
         pDegree_inc = 1.0)
      
     ### mill out the circle for the main
     ### hub area air entry
     ##mill.retract()
     ##aCircle.beg_depth = pBegZ
     ##aCircle.mill_pocket(lcx, lcy, 
     ##  air_entry_end_diam + mill.bit_radius, 
     ##  air_depth_entrance,
     ##  island_diam = 0)
       
     # cut the rest of the way over.
     curr_depth = pbot          
     mill.retract()
     cod = 0 - ((pEndZ - pBegZ) * 0.2).abs
     mill_cut_off_normal(pBegZ, cod)
     mill.home()
     
   end # layer separator and mill_lid_inner

   
   
   
   #  The main purpose of this layer
   #  is to provide the threaded pipe
   #  area for the exit air and to 
   #  provied a bearing holder for the 
   #  final axel part.
   #   
   #  The bottom plate is the mirror
   #  of the inlet.  with the 
   #  only difference being that it's
   #  exit area must have the transition
   #  hole for the volute area. to pipe.
   #  It also does not need an air mixing
   #  area and the axel hole only goes as deep
   #  as the bearing.
   #   
   #   #   #   #   #   #   #   #   #
   def mill_bottom_case(pBegZ=0, pEndZ=nil)
   #   #   #   #   #   #   #   #   #

    print "(CENTRIFUGE PUMP BOTTOM CASE)\n"
    
    
    if (pEndZ == nil)
      pEndZ = 0 - stock_z_len
    end
   
    curr_depth = pBegZ
    net_depth  = (pEndZ - pBegZ).abs
    air_gap    = 0 - (net_depth.abs * 0.25)
    mill.retract()          
   
   
    # Mill the shaft slot.
    mill.retract()
        
    print "\n\n(BEARING SOCKET)\n"
    curr_depth = mill_bearing_socket(pBegZ, bearing_thick)
    mill.retract()
      
    
  
    print "(RECT EXIT AIR CAVITY)\n"
    mill.retract()   
    edge_adjust = wall_thick + mount_bolts_diam + bolt_space_from_edge  
   
    if (1 == 99)
    beg_x = edge_adjust
    beg_y = edge_adjust
    rec_x_len = volute_len * 0.8
    rec_y_len = max_y - ((min_y + edge_adjust)/2.0)
  
      aRect =  CNCShapeRect.new(aMill,
      beg_x, 
      beg_y, 
      rec_x_len, 
      rec_y_len,
      air_gap)
      
    aRect.beg_depth = pBegZ        
    aRect.skip_finish_cut()
    aRect.do_mill()
    curr_depth = air_gap
    end #if
   
    mill.retract()
    mill_volute(pBegZ, air_gap, 0)
    
    # Mill the entrance as far away from motor
    # as possible and still be inside volute sized
    # area      
    # Position relative to the
    # rectangle
    print "\n\n(MAIN AIR OUTLET HOLE)\n"
    #print "(max_x = ", max_x, ")\n"
    #print "(max_y = ", max_y, ")\n"
    mill.retract()
    entrance_radius = entrance_diam / 2.0
    eny = max_y - (edge_adjust + entrance_radius)
    enx = min_x + (edge_adjust + entrance_diam)
    #print "(far_x = ", far_x, ")\n"
    #print "(far_y = ", far_y, ")\n"
    aCircle.beg_depth = 0
    aCircle.mill_pocket(enx, eny, 
      entrance_diam, 
      drill_through_depth, 
      island_diam=0)   
    mill.retract()     

    
    mill.retract()
    mill_bolts_normal(0, drill_through_depth)
    chamfer_corners(0, drill_through_depth)

    print "\n\n(CUT OUT)\n"     
    mill.retract()
    
    mill_cut_off_normal(0, pEndZ)
    
    
    mill.home()
   
   end # Method
   
   
   
    
   
    
     
     
     
     
   # The bottom plate is thicker
   # than the other plates and
   # has more holes to allow
   # air through.  It acts as the
   # sealing plate and the nut
   # for the threaded rod
   # We use a different stategy for milling these
   # sloping fan blades.  We basically
   # mill off the flat surface for each blade in
   # our standard cut depth incrments and then
   # mill off the next layer but skip any portion
   # of the blade that is above the new plane.
   # the intent is to minimize movment of the
   # bit in space where it isn't cutting anything
   #   #   #   #   #   #   #   #   #
   def mill_radial_bottom_plate
   #   #   #   #   #   #   #   #   #
     rim_thick = wall_thick * 0.5
       
     beg_diam   = shaft_diam + (rim_thick *2)+ mill.bit_diam

          #beg_radius = (shaft_diam / 2.0) + (rim_thick  / 2) + mill.bit_radius
     
     cut_out_diam = (wheel_diam + mill.bit_diam) - (min_wheel_clearance / 2)
     cut_out_radius = cut_out_diam / 2
     
     aMill.retract()   
        
     mill_radial_fan(aMill, 
       shaft_diam = self.shaft_diam * 0.85, 
       inside_diam = self.shaft_diam + wall_thick,  
       outside_diam = cut_out_diam,  
       material_thick = bottom_plate_thick,
       num_blades = 2, 
       rim_thick  = wall_thick)
       
     aMill.retract()   
   end
    
   
end #module


