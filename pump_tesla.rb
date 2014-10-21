# test_pump_housing_1.5_inch.rb
#
require 'cncMill'
require 'cncGeometry'
require 'cncShapeBase'
require 'cncShapeArcPocket'
require 'cncShapeSpiral'
require 'cncShapeSpiralFan'
require 'cncShapeCircle'
require 'cncShapeRect'
require 'cncShapeDShaft'



########################################
class Tesla_Pump 
########################################
   attr_accessor :air_gap_at_bottom, :amount_lopside, :bearing_inside_diam, :bearing_outside_diam, :bearing_thick, :bottom_plate_thick, :bolt_space_from_edge, :cut_off_allowance,  :drill_through_depth, :entrance_diam, :floor_thick,      :lcx, :lcy,  :lhub_diam, :lid_thick, :max_left, :mill, :min_wheel_clearance, :mount_bolts_diam, :mount_bolt_thread_diam, :mount_bolt_length, :mount_bolt_head_thick, :mount_bolt_head_diam,  :plate_thick,  :remove_surface, :shaft_diam, :stock_height, :stock_thick, :stock_width, :top_screw_thick, :wall_thick, :wheel_diam
   
   #   #   #   #   #   #   #   #   #
   def initialize(aMillIn)
   #   #   #   #   #   #   #   #   #
   @mill = aMillIn
   @stock_thick  = 0.75 #1.1    # Z AXIS
   @stock_width =  1.5  #2.8    # X AXIS
   @stock_height = @stock_width # Y AXIS
   @lid_thick    = 0.25
   @remove_surface = 0.01
   @max_left       = 0.0
   @wheel_diam     = 0
   @drill_through_depth = 0
   
   @amount_lopside = stock_width * 0.20
   @wall_thick         = 0.1
   @floor_thick        = wall_thick * 2
   @bottom_plate_thick = 0.125
   @top_screw_thick = 0.125
   @air_gap_at_bottom = 0.02
   @bearing_inside_diam = 0.25
   @bearing_outside_diam = 0.374
   @bearing_thick  = 0.125
   @lhub_diam      = bearing_outside_diam + (wall_thick * 0.8)
   @shaft_diam    = 0.25
   @min_wheel_clearance = 0.005
   @cut_off_allowance = aMillIn.bit_diam
   @plate_thick       = 0.030
   
   # Bolts that go from the top cover
   # down through the housing
   @mount_bolts_diam = 0.25
   @mount_bolt_thread_diam = mount_bolts_diam - 0.05
   @mount_bolt_length  = 0.64
   @mount_bolt_head_thick = 0.1
   @mount_bolt_head_diam  = 0.24
   @bolt_space_from_edge = 0.2
   @entrance_diam = 0.25
   full_recalc()
   end #meth
  
   # normal recalc does not change things that you may 
   # have reasonably overridden such as bolt length.
   # while full recalc resets all of these based on
   # our original assumptions. 
   #   #   #   #   #   #   #   #   #
   def full_recalc
   #   #   #   #   #   #   #   #   #
     @drill_through_depth = 0 - (@stock_thick + 0.05)   
     @amount_lopside = @stock_width * 0.20
     @floor_thick    = @wall_thick * 1
     
     @mount_bolt_thread_diam = @mount_bolts_diam - 0.05
     @mount_bolt_length  = @stock_thick + 0.05
     @cut_off_allowance = @mill.bit_diam
     recalc()
   end
   
   
    
   #   #   #   #   #   #   #   #   #
   def recalc   
   #   #   #   #   #   #   #   #   #
   
     @max_left = cut_off_allowance
     @wheel_diam = stock_width - ((wall_thick * 0)  + (min_wheel_clearance * 2) +  (amount_lopside))
     
     @lcx = max_left + wall_thick*2 + mount_bolts_diam + min_wheel_clearance + wheel_radius
     
     @lcy = wall_thick + min_wheel_clearance + wheel_radius 
     print "(stock width = ", stock_width, "  stock thick=", stock_thick, ")\n"
     print "(wheel diam = ", wheel_diam, ")\n"
     print "(lcx=", lcx,  " lcy=", lcy, ")\n"
     print "(max right=", max_right, ")\n"
     print "(drill through depth=", drill_through_depth, ")\n"
     
     print "(Amount of Unused Vertical space ", vertical_space_used_non_wheel(), ")\n"
     print "(Plate thickness ", plate_thick, ")\n"
     print "(Number of wheels ", number_of_wheels(), ")\n"
     
     @curr_depth = 0
        
     @main_wheel_thick = stock_thick - vertical_space_used_non_wheel 
     print "(main wheel thick=", @main_wheel_thick, ")\n"
     
   end
   
   
   def cavity_diam 
     return wheel_diam + (min_wheel_clearance)
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
     return floor_thick + bearing_thick + air_gap_at_bottom  + bottom_plate_thick + remove_surface
   end
   
   def number_of_wheels
      return (vertical_space_used_non_wheel / plate_thick).to_i
   end
   
   def max_right
     return lcx + cr2 + bolt_space_from_edge + wall_thick
   end
   
   
   def entrance_off_center_adj 
     return bearing_outside_diam / 2 +  aMill.bit_radius + wall_thick / 2
   end
   
      
   def aMill
     @mill
   end

   
   def lhub_diam
     bearing_outside_diam + (wall_thick * 3)   
   end
   
   #   #   #   #   #   #   #   #   #
   # Horizontally mirror a point (X Axis)
   # based on current size specifications
   #   #   #   #   #   #   #   #   #
   def hmirror(pxin)
     return  max_right - pxin
   end
   
  
   #   #   #   #   #   #   #   #   #
   # Vertically  mirror a point  (Y Axis)
   # based on current size specifications
   #   #   #   #   #   #   #   #   #
   def vmirror(pyin)
     return  stock_height - pyin
   end
   
   
   
   #   #   #   #   #   #   #   #   #
   def mill_body
   #   #   #   #   #   #   #   #   #
    aCircle = CNCShapeCircle.new(aMill) # this circle re-used several times below
      
     # Mill off the surface to make sure we get a smooth
     # seal
     # Mill out exit area 
     # where the outlet hole
     # will be drilled
      aMill.retract()  
     aRect =  CNCShapeRect.new(aMill,
        0, 
        0 - aMill.bit_radius / 2, 
        max_right + aMill.bit_radius/2, 
        stock_width + aMill.bit_radius/2,
        0 - remove_surface)
        
     aRect.skip_finish_cut()
     aRect.do_mill()
     aMill.retract()
     curr_depth_sub(remove_surface)
     
     aMill.retract()  
    #  Mill the exit hole
    cp = calc_point_from_angle(
                  lcx,
                  lcy, 
                  250, 
                  cr2 + (aMill.bit_radius / 8))

                  
     # Mill out exit area 
     # where the outlet hole
     # will be drilled
     end_y = bolt_space_from_edge + mount_bolt_thread_diam + wall_thick + aMill.bit_radius
     curr_y = cp.y 
     tSpeed = aMill.speed
     aMill.set_speed(tSpeed / 2.5)
     line_left = max_left + aMill.bit_radius + wall_thick
     line_depth = curr_depth - main_wheel_thick
     while (curr_y > end_y)
       beg_x = cp.x
       beg_y = cp.y + (amount_lopside * 0.2)
       end_x = beg_x
       end_y = curr_y
       aMill.move_fast(beg_x, beg_y)
       aMill.flat_line(beg_x, beg_y, 0 - (stock_thick - wall_thick), 
       end_x, end_y,  line_depth)       
       curr_y -= aMill.cut_inc 
       aMill.set_speed(tSpeed)
     end
     aMill.set_speed(tSpeed)
     aMill.flat_line(cp.x,cp.y, curr_depth, 
       line_left, end_y,  line_depth)       
       curr_y -= aMill.cut_inc   
       
     aMill.retract(curr_depth)    
     
        
    mill_lopsided_circle(aMill, lcx, lcy, cavity_diam, cavity_diam + amount_lopside, -105.0, 245.0,curr_depth,curr_depth - main_wheel_thick)
   
    
   
      
    curr_depth_sub(main_wheel_thick)
    aMill.retract(curr_depth)
    aMill.move(lcx,lcy)
    #print "(Top of bearing slot=", curr_depth, ")\n"
     # This is the slot to hold the starting wheel.
     # this sheel also acts like the plug for the 
     # inlet air on that side.
     aMill.retract(curr_depth)
     
     #aMill.pause("Mill slot to accept thicker bottom wheel")
     
     bearing_vert_exposed = bearing_thick * 0.2
     bottom_plate_vert_space = bottom_plate_thick + (bearing_vert_exposed) + air_gap_at_bottom
     
     aCircle.beg_depth = curr_depth
     aCircle.mill_pocket(lcx, lcy, 
       wheel_diam + min_wheel_clearance, 
       curr_depth - bottom_plate_vert_space,
       island_diam = 0)
    
     
    
     curr_depth_sub(bottom_plate_thick - bearing_vert_exposed)
     
     #aMill.pause("mill bearing holder")
     #aMill.retract(curr_depth)  
     aMill.retract() 
     aCircle.beg_depth = curr_depth - 
     aCircle.mill_pocket(lcx, lcy, bearing_outside_diam, 
       curr_depth - (bearing_thick * 0.8) ,  
       island_diam=0)   
     
     aMill.retract()
     #aMill.retract(curr_depth)
     #aMill.pause("drill center hole")
     aMill.drill(lcx, lcy, curr_depth, drill_through_depth) 
     aMill.retract() 
   
     #aMill.pause("mill out air space hole")
        
     
     retract_depth = curr_depth #+ bearing_thick  +air_gap_at_bottom

        
     aMill.retract(retract_depth) 
     tSpeed = aMill.speed
     aMill.set_speed(tSpeed/3) # slow down for full on cut
     mill_circle(aMill, lcx,lcy,
         wheel_diam + min_wheel_clearance,
         curr_depth,
         curr_depth -  bearing_thick,
         adjust_for_bit_radius = true)
     aMill.set_speed(tSpeed)
         
         
     #aMill.pause("mill out entrance hole  #1")    
     #curr_depth -= bearing_thick  
     aMill.retract(retract_depth) 
     aMill.drill(
       lcx - entrance_off_center_adj, 
       lcy, 
       curr_depth, drill_through_depth) 

     #aMill.pause("mill out entrance hole  #1")         
     aMill.retract(retract_depth) 
     aMill.drill(
       lcx + entrance_off_center_adj,
       lcy, 
       curr_depth,  drill_through_depth) 
       
     #aMill.pause("mill out entrance hole  #1")      
     aMill.retract(retract_depth) 
     aMill.drill(lcx, 
       lcy - entrance_off_center_adj, 
       curr_depth, drill_through_depth) 
       
     #aMill.pause("mill out entrance hole  #1")      
     aMill.retract(retract_depth) 
     aMill.drill(
       lcx, 
       lcy + entrance_off_center_adj, 
       curr_depth, drill_through_depth) 
    
       
     
     
     # --------------
     # -- ADD THE 4 Corner Mounting
     # -- holes
     # -------------         
     #aCircle.beg_depth = 0  
     curr_depth = 0 - remove_surface
     bolt_depth = drill_through_depth
     
     aMill.drill(
       max_left + bolt_space_from_edge,
       bolt_space_from_edge, 
       curr_depth, 
       bolt_depth) 
     
     aMill.retract()   
     aMill.drill(
       max_left + bolt_space_from_edge,
       stock_height - bolt_space_from_edge, 
       curr_depth, 
        bolt_depth) 
          
     aMill.retract()     
     aMill.drill(
      max_right - bolt_space_from_edge,
      stock_height - bolt_space_from_edge, 
      curr_depth, 
      bolt_depth)
 
     aMill.retract()      
     aMill.drill(
       max_right - bolt_space_from_edge,
       bolt_space_from_edge, 
       curr_depth, 
       bolt_depth) 
       
     aMill.retract() 
  
  # chamfer the corners
  #aMill.flat_line(0.05
  
  
  # Assuming item is held on the left
  # cut off the right end first.      
  aMill.cut_off(
      bx = max_right + aMill.bit_radius,      
      by = 0 - 0.02,
      bz = 0 - remove_surface,
      ex = max_right + aMill.bit_radius,
      ey = stock_width + 0.02,
      ez = 0 - (stock_thick + 0.01))  
  
  
   aMill.retract()          
   
   # now cut off the left end       
   aMill.cut_off(
      bx = 0 + aMill.bit_radius,      
      by = 0 - 0.02,
      bz = 0 - remove_surface,
      ex = 0 + aMill.bit_radius,
      ey = stock_width + 0.02,
      ez = 0 - (stock_thick + 0.01))
 
     
   aMill.retract()
   end  # mill_body # 
      
   
   
   
   
   
   #   #   #   #   #   #   #   #   #
   # The lid has to be the mirror
   # of the top.  I assume we will
   # flip on the Y axis so we mirror
   # only that axis -  Alternatively I 
   # could make it exactly the same
   # as the top but then we would
   # not have the bearing holder.
   #   #   #   #   #   #   #   #   #
   def mill_lid
   #   #   #   #   #   #   #   #   #
      print "(mill tesla lid)\n"
      print "(This item is mirrored on the X axis to the)\n"
      print "(bolt pattern, bearing support and axel to the)\n"
      print "(body so that when flipped over the bolt pattern matches)\n"
    cut_through = lid_thick + 0.01
    curr_depth = 0
    aCircle = CNCShapeCircle.new(aMill) # this circle re-used several times below
      
     # Mill off the surface to make sure we get a smooth
     # seal
     # Mill out exit area 
     # where the outlet hole
     # will be drilled
      aMill.retract()  
     aRect =  CNCShapeRect.new(aMill,
        0, 
        0 - aMill.bit_radius / 2, 
        max_right + aMill.bit_radius/2, 
        stock_width + aMill.bit_radius/2,
        0 - remove_surface)
        
     aRect.skip_finish_cut()
     aRect.do_mill()
     aMill.retract()
     curr_depth_sub(remove_surface)
     
     bearing_vert_exposed = bearing_thick * 0.05
     bottom_plate_vert_space = bottom_plate_thick + (bearing_vert_exposed) + air_gap_at_bottom   
     bearing_mill_depth =   bearing_thick - bearing_vert_exposed
     aMill.retract() 
     
     mcy = vmirror(lcy)
     
     aCircle.beg_depth = curr_depth
     aCircle.mill_pocket(lcx, mcy, bearing_outside_diam, 
       curr_depth - bearing_mill_depth, 
       island_diam=0)   
     
     curr_depth_sub(bearing_mill_depth)
       
     aMill.retract()
     #aMill.retract(curr_depth)
     #aMill.pause("drill center hole")
     aMill.drill(lcx, vmirror(lcy), curr_depth, cut_through) 
     aMill.retract() 
     
     retract_depth = curr_depth #+ bearing_thick  +air_gap_at_bottom

     
     
     # --------------
     # -- ADD THE 4 Corner Mounting
     # -- holes
     # -------------         
     #aCircle.beg_depth = 0  
     curr_depth = 0 - remove_surface
     bolt_depth = drill_through_depth
     
     aMill.drill(
       max_left + bolt_space_from_edge,
       vmirror(bolt_space_from_edge), 
       curr_depth, 
       cut_through) 
     
     aMill.retract()   
     aMill.drill(
       max_left + bolt_space_from_edge,
       vmirror(stock_height - bolt_space_from_edge), 
       curr_depth, 
        cut_through) 
          
     aMill.retract()     
     aMill.drill(
      max_right - bolt_space_from_edge,
      vmirror(stock_height - bolt_space_from_edge), 
      curr_depth, 
      cut_through)
 
     aMill.retract()      
     aMill.drill(
       max_right - bolt_space_from_edge,
       vmirror(bolt_space_from_edge), 
       curr_depth, 
       cut_through) 
       
     aMill.retract() 
  
  # chamfer the corners
  #aMill.flat_line(0.05
  
  
  # Assuming item is held on the left
  # cut off the right end first.      
  aMill.cut_off(
      bx = max_right + aMill.bit_radius,      
      by = 0 - 0.02,
      bz = 0 - remove_surface,
      ex = max_right + aMill.bit_radius,
      ey = stock_width + 0.02,
      ez = 0 - cut_through)    
  
  
   aMill.retract()          
   
   # now cut off the left end       
   aMill.cut_off(
      bx = 0 + aMill.bit_radius,      
      by = 0 - 0.02,
      bz = 0 - remove_surface,
      ex = 0 + aMill.bit_radius,
      ey = stock_width + 0.02,
      ez = 0 - cut_through)    
 
     
   aMill.retract()
 
   end # mill_lid method
   
   
   
   
   
   
   
   
   
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
  
   
   
   
   
   
   
   
   # Mill the tesla bottom plate 
   #
   # Note:  The bottom plate doesn't
   #   actually need to turn as long as 
   #   it has a good 
   #   air entry area in the center prat of the 
   #   wheels wheels.  The disadvantage of that
   #   is that it would need a good seal to the
   #   next plate and it will be easier to allow
   #   the heavy bottom plate to reinforce the
   #   other plates for stability.
   #   #   #   #   #   #   #   #   #
   def mill_bottom_plate
   #   #   #   #   #   #   #   #   #
      print "(MILL BOTTOM PLATE)\n"
      aDrill_through = 0 - (bottom_plate_thick + 0.02)
      air_area_depth    = bottom_plate_thick * 0.6
      
      
      old_bit = aMill.current_bit
      bit2 = CNCBit.new(aMill, "config/bit/carbide-0.125X0.5X1.5-4flute.rb")
      aMill.curr_bit = bit2
      bit2.recalc()

      rim_thick = wall_thick / 2.0
      air_area_beg_diam = shaft_diam + wall_thick + mill.bit_diam
      air_area_end_diam = wheel_diam / 4
      tcx = wheel_diam / 2 + mill.bit_diam + 0.01
      tcy = tcx
      cut_out_diam = (wheel_diam + mill.bit_diam) - (min_wheel_clearance / 2.0)
      cut_out_radius  = cut_out_diam / 2.0
      
      print "(bottom_plate_thick = ", bottom_plate_thick, ")\n"
      print "(aDrill Through = ", aDrill_through, ")\n"
      print "(cut_out_diam=", cut_out_diam, ")\n"
      print "(rim_thick=", rim_thick, ")\n"
      mill.pause("insert 1/8th inch bit")

            
      if (air_area_end_diam < (air_area_beg_diam + mill.bit_diam))
          # for small wheels we have to increase
          # the air area to at least one bit diameter
          air_area_end_diam = air_area_beg_diam + mill.bit_diam
      end #if
      
      
      print "(air_area_beg_diam=", air_area_beg_diam, ")\n"
      print "(air_area_end_diam=", air_area_end_diam, ")\n"
      
      # JOE Decided didn't need this since we are milling
      # the segment pockets anyway
      # mill out area around axel to be 1/2 thick 
      # out to edge of the main area
      #mill.retract()
      #aCircle = CNCShapeCircle.new(aMill)
      # aCircle.beg_depth = 0.0
      # aCircle.mill_pocket(tcx, tcy, 
      # air_area_end_diam + wall_thick, 
      # 0 - air_area_depth,
      # island_diam =  air_area_beg_diam)
      #curr_depth = 0 - air_area_depth
      
         
      # mill the keyed axel holder
      #mill.retract(2.0)
      #mill.pause("Please insert 1/8 inch 0.125 bit for keyed axel")
      mill.retract()
      mill_DShaft(aMill, x = tcx,y=tcy, diam=0.22, beg_z=0.0, end_z= aDrill_through, adjust_for_bit_radius=true)
      
      #mill.pause("Please insert keyed holder to retain in place during cutout operation")
      
       
       
      curr_depth = 0 - air_area_depth
      
      # Mill out center holes as large as possible
      # without comprimising strength
      num_holes = 3
      degrees_per_hole = 360 / num_holes
      usable_degrees   = degrees_per_hole * 0.6 
      beg_degree = 0
      for hole_num in (1..num_holes)
        mill.retract()
        arc_segment_pocket(
          mill, 
          tcx,
          tcy,
          air_area_beg_diam / 2,
          air_area_end_diam / 2,  
          beg_degree,
          beg_degree + usable_degrees ,  
          0,
          aDrill_through
          )                    
         # mill,  circ_x, circ_y, min_radius, max_radius,     
         # beg_angle,   end_angle,    depth = nil,   
         # degree_inc = nil)
   
          
         beg_degree += degrees_per_hole
       end #for
       mill.retract()
 

      # mill cutout of edge
       print "(preparing to do final cutout)\n" 
       mill.retract()
       curr_cepth = 0
       mill.move_fast(tcx - cut_out_radius, tcy)
       spiral_down_circle(mill, tcx,tcy,
         cut_out_diam,
         0,
         aDrill_through,
         adjust_for_bit_radius = false,
         auto_speed_adjust = false)
     mill.retract()   
   end #meth
   
   
   
   
   
   
   
   
   
   
   # These are the actual Tesla turbine plates.
   # Generally we will need between 3 and 20
   # of these.   This routine figures out a 
   # matrix and mills multiple as many as will
   # fit in the stock until the limit is reached.   
   #   #   #   #   #   #   #   #   #
   def mill_plates(stock_x_len, stock_y_len, stock_thick,  num_items)
   #   #   #   #   #   #   #   #   #
     old_lcx = lcx
     old_lcy = lcy
     cut_out_diam = (wheel_diam + mill.bit_diam)
     space_between = 0.15
     unit_size = cut_out_diam + space_between
     unit_radius = unit_size / 2
     border_size = 0.1
     
      if (stock_y_len > mill.max_y)
       print "(warning machine only has ", mill.max_y, " Y capability so can not fully utilize ", stock_y_len, ")\n"
       stock_y_len = mill.max_y
     end
     
     if (stock_x_len > mill.max_x)
       print "(warning machine only has ", mill.max_x, "X  capability so can not fully utilize ", stock_x_len, ")\n"
        stock_x_len = mill.max_x
     end
     
    
     stock_x_len -= border_size * 2
     stock_y_len -= border_size * 2
     no_items_x = (stock_x_len / unit_size).to_i
     no_items_y = (stock_y_len / unit_size).to_i
     no_finished = 0
     
  
     
     
     
     print "(Can fit ", no_items_x, " in X axis of ", stock_x_len, ")\n"
     print "(Can fit ", no_items_y, " in Y axis of " ,stock_y_len,  ")\n"
    
     mill.pause("insert 1/8th inch bit")
    
     for item_x in (0..(no_items_x-1))       
       for item_y in (0..(no_items_y-1))
         lcx = curr_x = border_size + (item_x * unit_size) + unit_radius
         
         lcy = curr_y = border_size + (item_y * unit_size) + unit_radius + 0.03
         
         print "(item_x cnt=", item_x,  " item_y cnt=", item_y, ")\n"
         print "(curr_x =", curr_x, "  curr_y=", curr_y, ")\n"
         
         mill_plate(curr_x, curr_y, stock_thick)
         
         no_finished += 1
         if (no_finished >= num_items)
           mill.retract()
           mill.job_finish()
           #lcx = old_lcx
           #lcy = old_lcy    
           return
         end
       end #for y
     end # for x
   end
     
    
   
   
   # These are the actual Tesla turbine plates.
   # Generally we will need between 3 and 20
   # of these.
   #   #   #   #   #   #   #   #   #
   def mill_plate(pCent_x,  pCent_y,  plate_thickness)
   #   #   #   #   #   #   #   #   #
      print "(MILL PLATES pCent_x=", pCent_x, " pCent_y=", pCent_y, ")\n"     
      print "(plate_thick = ", plate_thickness, ")\n"
      
      plate_through = 0 - (plate_thickness + 0.009)
      print "(plate_through = ", plate_through, ")\n"
      
      air_area_depth = plate_thickness * 0.60
      rim_thick = wall_thick / 2
      print "(Air area depth =", air_area_depth, ")\n"
      print "(rim_thick =",  rim_thick, ")\n"
      
      old_bit = aMill.current_bit
      bit2 = CNCBit.new(aMill, "config/bit/carbide-0.125X0.5X1.5-4flute.rb")
      aMill.curr_bit = bit2
      bit2.recalc()
      print "(new bit diam=", mill.bit_diam,  " radius=", mill.bit_radius, ")\n"
      
    
      print "(center pCent_x=", pCent_x, "  center pCent_y = ", pCent_y, ")\n"
      
      
      cut_out_diam = (wheel_diam + mill.bit_diam)
      cut_out_radius  = cut_out_diam / 2.0
      print "(Cut out diameter=", cut_out_diam, ")\n"
      
      
      calc_wing_height = wheel_diam * 0.1           
      if (calc_wing_height < rim_thick* 3)
         calc_wing_height = rim_thick * 3
      end      
      print "(calc wing height=",  calc_wing_height, ")\n"
      
      
      
      inlet_beg_diam = shaft_diam + rim_thick * 1.5
      inlet_diam     = wheel_diam * 0.25
      if (inlet_diam < mill.bit_diam)
        inlet_diam == mill.bit_diam
      end
      inlet_end_diam = inlet_beg_diam + inlet_diam
      inlet_beg_radius = inlet_beg_diam / 2.0
      inlet_end_radius = inlet_end_diam / 2.0
      print "(inlet_beg_diam=",  inlet_beg_diam, ")\n"
      print "(inlet_end_diam=",  inlet_end_diam, ")\n"
      
        
      spoke_length = wheel_diam * 0.1
      if (spoke_length < rim_thick)
        spoke_length = rim_thick * 2
      end      
      spoke_beg_diam = inlet_end_diam
      spoke_end_diam = spoke_beg_diam + spoke_length
      spoke_beg_radius = spoke_beg_diam / 2.0
      spoke_end_radius = spoke_end_diam / 2.0
      print "(spoke_beg_diam=", spoke_beg_diam, ")\n"
      print "(spoke_length=",  spoke_length, ")\n"    
      print "(spoke_end_diam=", spoke_end_diam, ")\n"
      print "(spoke_beg_radius=", spoke_beg_radius, ")\n"
      print "(spoke_end_radius=", spoke_end_radius, ")\n"
    
      air_beg_diam = spoke_end_diam           
      air_end_diam = wheel_diam - calc_wing_height
      if (air_beg_diam > air_end_diam)
         air_end_diam = air_air_beg_diam
         print "(Warning no room for air area)"
      end
      air_beg_radius = air_beg_diam / 2.0
      air_end_radius = air_end_diam / 2.0
      print "(air_beg_diam=", air_beg_diam, ")\n" 
      print "(air_end_diam=", air_end_diam, ")\n"
      print "(air_beg_radius=", air_beg_radius, ")\n" 
      print "(air_end_radius=", air_end_radius, ")\n"
     
      
       # Trace the outer wheel So we get a cleaner
       # finish.  We trace a little larger so when
       # we come back to cut it out latter we get
       # a good cut.
       print "(trace outline)"      
      
       
       mill.retract()
       curr_cepth = 0
       mill.move_fast(pCent_x - cut_out_radius, pCent_y)
       spiral_down_circle(mill, pCent_x,pCent_y,
         cut_out_diam + mill.cut_inc * 0.4,
         0,
         plate_through * 0.50,
         adjust_for_bit_radius = false,
         outside = true,
         auto_speed_adjust = false)
       
           
      tSpeed = mill.speed
      mill.set_speed(tSpeed * 2.5)
      
         
      # mill the keyed axel holder
      mill.retract()
      mill_DShaft(aMill, x = pCent_x,y=pCent_y, diam=0.22, beg_z=0.0, end_z= plate_through, adjust_for_bit_radius=true)
       
      mill_end_slots(mill,pCent_x,pCent_y,
           (air_beg_diam + air_end_diam) / 2.0,
           wheel_diam + mill.bit_radius, 
            6, 0,
            0- air_area_depth)
      
      # Mill out center holes as large as possible
      # without comprimising strength
      num_holes = 3
      degrees_per_hole = 360 / num_holes
      usable_degrees   = degrees_per_hole * 0.85    
      beg_degree = 0                
      for hole_num in (1..num_holes)
        mill.retract()
       
        print "(mill_plate in arc loop x=", pCent_x, " y=", pCent_y, ")\n"
        
        arc_segment_pocket(
          mill, 
          pCent_x,
          pCent_y,
          inlet_beg_radius,
          air_end_radius,  
          beg_degree,
          beg_degree + (usable_degrees),  
          0,
          0- air_area_depth
          ) 
         
        mill.retract(0-air_area_depth)
        arc_segment_pocket(
          mill, 
          pCent_x,
          pCent_y,
          inlet_beg_radius,
          inlet_end_radius,  
          beg_degree,
          beg_degree + usable_degrees ,  
          plate_through
          )  
          mill.retract()
          
        
           
                                                              
        beg_degree += degrees_per_hole 
         
       end #for
       
      
         
      
     
      
      # Mill out the Air area
      mill.retract()
      aCircle = CNCShapeCircle.new(aMill)
       aCircle.beg_depth = 0.0
       aCircle.mill_pocket(pCent_x, pCent_y, 
       air_end_diam, 
       0 - air_area_depth,
       island_diam =  air_beg_diam - mill.bit_radius)       
       curr_depth = 0 - air_area_depth 
              
      mill.set_speed(tSpeed)     
      

      # mill cutout of edge almost all the
      # way through.
       print "(preparing to do final cutout)\n" 
       mill.retract(0.05)
       curr_cepth = 0
       mill.move_fast(pCent_x - cut_out_radius, pCent_y)
       spiral_down_circle(mill, pCent_x,pCent_y,
         cut_out_diam,   
         0,     
         plate_through * 0.80,
         adjust_for_bit_radius = false,
         auto_speed_adjust = false)
     mill.retract()   
     
      mill.retract(0.05)
       curr_cepth = 0
       mill.move_fast(pCent_x, pCent_y - cut_out_radius)  
            
       # Trim around the top edges.
       mill_circle_s(mill, pCent_x,pCent_y, 
          cut_out_diam - (mill.bit_radius), 
          0 - (plate_through * 0.02),
          adjust_for_bit_radius=false, outside=true)
     
       # retrace the end slots to get a better finish
       mill_end_slots(mill,pCent_x,pCent_y,
           (air_beg_diam + air_end_diam) / 2.0,
           wheel_diam + mill.bit_radius, 
            6, 
            0- (air_area_depth),
            0- (air_area_depth + (air_area_depth * 0.001)))    
     
     # Cut the rest of the way except for 4 spikes
     mill.retract()
     num_spikes = 4
     width_of_segment = 360 / num_spikes
     width_of_spike = 20
     width_mill_area = width_of_segment - width_of_spike     
     beg_degree = 0
     curr_depth = (plate_through * 0.80) - mill.cut_depth_inc
     while (true) 
       curr_depth -= mill.cut_depth_inc
       next_depth = curr_depth - mill.cut_depth_inc
       if (next_depth < plate_through)
         next_depth = plate_through
       end
       if (curr_depth < plate_through)
         curr_depth = plate_through        
       end
       for spik_num in 1..num_spikes
         mill.retract()       
         changing_radius_curve(mill, pCent_x,pCent_y,cut_out_diam/2, beg_degree,  curr_depth,  cut_out_diam/2, 
           beg_degree + width_mill_area,
           next_depth,  pDegrees_per_step=2.0, pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=false)
         beg_degree += width_of_segment        
       end #for segments
       mill.retract()
       if (curr_depth == plate_through)
         break
       end
     end #while depth
       
     
     mill.home()
     
 
     
   end
   
   
   # # # # # # # # # # # # # # #        
   def mill_end_slots(mill, xi,yi, beg_diam,  end_diam,  num_holes, beg_z, end_z)
   # # # # # # # # # # # # # # # 
      print "(mill end slots end_z=", end_z, ")\n"
      # Mill out the slots on the end
      degrees_per_hole = 360 / num_holes
      usable_degrees   = degrees_per_hole * 0.3   
      beg_degree = 0                
      degrees_in_bit_radius = degrees_for_distance(wheel_diam / 2, mill.bit_radius) * 1.2
      mill.plung(beg_z)
      for hole_num in (1..num_holes)
        mill.retract()  
        end_degree = beg_degree + usable_degrees
        curr_degree = beg_degree        
        while(true)      
           arc_to_radius(mill, xi, yi, beg_diam, curr_degree, end_diam,  curr_degree + 10,   beg_z, end_z,
             1,1)             
           #mill.retract(0.005)
          if (curr_degree == end_degree)
            break
          else
            curr_degree += degrees_in_bit_radius
            if (curr_degree > end_degree)
              curr_degree = end_degree
            end
          end
        end #while
        mill.retract()
        beg_degree += degrees_per_hole
      end #for
      mill.retract()
    end #meth
   
   
   
   # This will require turning the part over
   # and inserting 
   #   #   #   #   #   #   #   #   #
   def mill_larger_inlet
   #   #   #   #   #   #   #   #   #
   end
   
   #   #   #   #   #   #   #   #   #
   def mill_side_outlet
   #   #   #   #   #   #   #   #   #
   end
   
   # This tacks on the back and
   # contains the eletric motor.  
   # may require qty 2 1.2 inch
   # pieces
   #   #   #   #   #   #   #   #   #
   def  mill_motor_housing
   #   #   #   #   #   #   #   #   #
   end
   
   
   
end #class

########################
## Main porgram area
#######################

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
 tp = Tesla_Pump.new(aMill)   
   tp.stock_thick  = 0.75 #1.1
   tp.stock_width =  1.5  #2.8
   tp.remove_surface = 0.01
   tp.stock_width = 1.5
   tp.recalc()
   
   
   option  = 3

   
print "(option =", option, ")\n" 
if (option == 1)
   # Mill the Tesla pump housing for
   #  1.5" wide by 3/4" stock.
  tp.mill_body()       
elsif (option == 2)
  print "(Calling mill_bottom_plate)\n"
  tp.mill_bottom_plate()
elsif (option == 3)
  tp.mill_lid()
elsif (option == 4)
  #tp.mill_plates
  tp.mill_plates(
     stock_x_len = 10.75, 
     stock_y_len=5, 
     stock_thick=0.030,  
     num_items=10)
     
elsif (option == 5)
  tp.mill_side_outlet
end #if

