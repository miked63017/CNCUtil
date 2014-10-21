# cncShapeCentrifugePump.rb
#
require 'CNCMill'
require 'CNCGeometry'
require 'CNCShapeBase'
require 'CNCShapeArc'
require 'CNCShapeArcPocket'
require 'CNCShapeSpiral'
require 'CNCShapeSpiralFan'
require 'CNCShapeCircle'
require 'CNCShapeRect'
require 'CNCShapeDShaft'
require 'Pump_centrifuge_impeller_simple'
require 'Pump_centrifuge_impeller_small'
require 'Pump_centrifuge_impeller_strong'
require 'Pump_centrifuge_impeller_paddle'
require 'Pump_centrifuge_impeller'
require 'Pump_centrifuge_body'
require 'Pump_centrifuge_monolithic_body'
require 'Pump_centrifuge_util'
require 'radial_fan'
require 'Pump_centrifuge_diffuser'


########################################
class  Pump_Centrifuge
########################################
  
   attr_accessor :air_gap_at_bottom
   attr_accessor :amount_lopside, :bearing_inside_diam, :bearing_outside_diam, :bearing_thick, :nub_thick, :nub_width, :nub_num
   attr_accessor :bottom_plate_thick, :bolt_space_from_edge, :cut_off_allowance,  :entrance_diam
   attr_accessor :exit_pocket_arc_beg_deg, :exit_pocket_arc_end_deg, :floor_thick
   attr_accessor :lcx, :lcy,  :hub_diam, :hub_nut_thick,  :hub_wall_thick
   attr_accessor :lid_thick, :lopside_percent, :material_type, :mill  
   attr_accessor :min_wheel_clearance, :mount_bolts_diam, :mount_bolt_thread_diam, :mount_bolt_length
   attr_accessor :mount_bolt_head_diam, :mount_bolt_head_thick, :plate_thick,  :remove_surface_amt
   attr_accessor :stock_z_len, :stock_x_len, :stock_y_len
   attr_accessor :top_screw_thick, :volute_len, :wall_thick, :shaft_diam, :shaft_type
   attr_accessor :wheel_thick,  :x_adj, :y_adj, :wheel_diam,:mirror_impellor, :wheel_type, :diffuser_width,:wheel_lid_thick,  :wheel_wobble_room, :volute_width_right, :volute_width_left 

   include   Pump_centrifuge_util
   extend    Pump_centrifuge_util  
   
   include   Pump_centrifuge_impeller
   extend    Pump_centrifuge_impeller
   include   Pump_centrifuge_impeller_simple
   extend    Pump_centrifuge_impeller_simple
   include   Pump_centrifuge_impeller_small
   extend    Pump_centrifuge_impeller_small
   include   Pump_centrifuge_impeller_strong
   extend    Pump_centrifuge_impeller_strong
   include   Pump_centrifuge_impeller_paddle
   extend    Pump_centrifuge_impeller_paddle
   
   
   include   Pump_centrifuge_body
   extend    Pump_centrifuge_body
   include   Pump_centrifuge_monolithic_body
   extend    Pump_centrifuge_monolithic_body
   
   include   Pump_centrifuge_diffuser
   extend    Pump_centrifuge_diffuser
    
     
   #   #   #   #   #   #   #   #   #
   def initialize(aMillIn)
   #   #   #   #   #   #   #   #   #
   print "(pump_centrifuge initialize)\n"
   @mill = aMillIn
   @stock_z_len        = 0.25 #1.1    # Z AXIS
   @stock_x_len        =  5.5 #2.8    # X AXIS
   @hub_nut_thick      = 0.125
   @hub_wall_thick     = 0.125
   @stock_y_len        = 3.5 # Y AXIS
   @lid_thick          = 0.25
   @remove_surface_amt = 0.01
   
   print "(stock_z_len=", stock_z_len, ")\n"
   @wheel_diam         = 1.0  # one inch
   @wheel_thick        = 0.1  # 1/10 of inch
   @wheel_lid_thick    = 0.09
   @wheel_wobble_room  = 0.05 
   
   @amount_lopside      = stock_x_len * 0.30
   @wall_thick          = 0.1
   @floor_thick        = wall_thick
   @bottom_plate_thick = 0.0625
   @top_screw_thick = 0.125
   @air_gap_at_bottom = 0.02
   @bearing_inside_diam = 0.24
   @bearing_outside_diam = 0.374
   @bearing_thick  = 0.125
   @shaft_diam    = 0.25  # 1/4 inch
   @min_wheel_clearance = 0.03
   @cut_off_allowance = aMillIn.bit_diam
   @plate_thick       = 0.030
   
   # Bolts that go from the top cover
   # down through the housing
   @mount_bolts_diam = 0.23
   @mount_bolt_thread_diam = mount_bolts_diam - 0.05
   @mount_bolt_length  = 0.64
   @mount_bolt_head_thick = 0.1
   @mount_bolt_head_diam  = 0.36
   @bolt_space_from_edge = 0.2
   @entrance_diam = 0.25
   @shaft_type = "D"
   @material_type = "aluminum6010"
   @volute_width_right = 1.0
   @volute_width_left  = 1.0
   @x_adj  = mill.bit_diam
   @y_adj  = mill.bit_radius
   @lopside_percent = 0.30
   @exit_pocket_arc_beg_deg = 230
   @exit_pocket_arc_end_deg = 270
   @blade_depth = nil
   @mirror_impellor = false
   
   @tCircle = CNCShapeCircle.new(aMill) 
   @entrance_diam = 0.5
   @lcx = 0
   @lcy = 0
   
   @wheel_type = "spike"   # types  = spike  # implemented by simple
                           #          strong # implemented by small.
                           #          tesla
                           #          normal
                           
   # cutout nubs are the small pieces of material
   # left in place so that things like wheels will
   # remain attached to the clamped down stock but
   # which can easily be removed to allow cleanup
   # afterwords.  @nub_thick is how thick on the
   # Z axis the nubs should be.  @nub_width is
   # how wide the nubs should be.  @nub_num is
   # how many nubs we want.  More nubs hold better
   # but require more cleanup.                     
   @nub_thick = 0.03
   @nub_width = 0.1
   @nub_num   = 6
   
   @diffuser_width = 0.4
   
   
       
                                             
   full_recalc()
   end #meth


   
     
   # normal recalc does not change things that you may 
   # have reasonably overridden such as bolt length.
   # while full recalc resets all of these based on
   # our original assumptions. 
   #   #   #   #   #   #   #   #   #
   def full_recalc
   #   #   #   #   #   #   #   #   #   
     print "(FULL RECALC)\n"
     @hub_diam      = bearing_outside_diam + (wall_thick * 0.8)
    
     @amount_lopside = wheel_diam * lopside_percent
     @floor_thick    = @wall_thick * 1     
     @mount_bolt_thread_diam = @mount_bolts_diam * 0.85
     @mount_bolt_length  = @stock_z_len + 0.05
     @cut_off_allowance = @mill.bit_diam
     print "(hub_diam=", @hub_diam, ")\n"
     recalc()
   end
   
   
    
   #   #   #   #   #   #   #   #   #
   def recalc   
   #   #   #   #   #   #   #   #   #
     print "(RECALC)\n"
     print "(wheel_radius=", wheel_radius, ")\n"
     @lcx = (min_x + wall_thick 
          + bolt_space_from_edge + mount_bolts_diam +  min_wheel_clearance  + diffuser_width +  volute_width_left + wheel_radius)
     
     print "(lcx = ", lcx,")\n"
     
     @lcy = (y_adj + wall_thick + bolt_space_from_edge + min_wheel_clearance + wheel_radius + diffuser_width)
     
     print "(lcy=", lcy, ")\n"
     
     print "(stock width = ", stock_x_len, "  stock thick=", stock_z_len, ")\n"
     print "(wheel diam = ", wheel_diam, ")\n"
     print "(wheel_thick= ", wheel_thick, ")\n"
    
     
      
     print "(max_y=", max_y, " min_y=", min_y, ")\n"
     print "(min_x=", min_x, " max_x=", max_x, ")\n"
     print "(lcx=", lcx,  " lcy=", lcy, ")\n"
  
     if (stock_y_len < max_y)
       print "(WARNING stock is not large enough on Y axis)\n"
     end
     @curr_depth = 0
    
   end
   
  
   
     
   #  #  #  #  #  #  #  #  #  #  #  #  #  #  
   #  Mill a set of pump wheels
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def  mill_pump_wheels()
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
     cx =  (mill.bit_radius / 6.0 ) + (wheel_diam / 2)
     cy = cx
     pCent_x = cx
     pCent_y = cy
          
     if (wheel_diam <= (mill.bit_diam * 100))  # normally *10
       return mill_small_diameter_pump_wheel(pCent_x, pCent_y)
     elsif  @wheel_type == "strong"   # types  = small      
       return mill_small_diameter_pump_wheel(pCent_x, pCent_y)
     elsif wheel_type == "spike"
       return mill_simple_pump_wheel(pCent_x = cx, pCent_y = cy)
     elsif wheel_type == "tesla"
       return mill_pump_wheel_tesla(cx,cy)     
     else     
       return mill_pump_wheel(cx,cy)
     end          
  end #meth
  
  
    
   
   
   # This tacks on the back and
   # contains the eletric motor.  
   # may require qty 2 1.2 inch
   # pieces
   #   #   #   #   #   #   #   #   #
   def  mill_motor_housing
   #   #   #   #   #   #   #   #   #
   end
   
   
      
end #class



#   #   #   #   #   #   #   #   #
def main_pump_centrifuge(option, sub_option=1)
#   #   #   #   #   #   #   #   #
  ########################
  ## Main porgram area
  #######################
  
  aMill = CNCMill.new()
  aMill.job_start()
  aMill.home()
  
  
  #aMill.load_bit("config/bit/carbide-0.250X0.75X2.5-6flute.rb"), "Load 1/4 inch 6 floot bit", 0.5, nil)
  
  #aMill.load_bit("config/bit/carbide-0.125X0.5X1.5-4flute.rb"), "Load 1/8 inch 4 floot bit", 0.5, nil)
  
  
  
   tp = Pump_Centrifuge.new(aMill)   
     tp.stock_z_len  = 0.75 #1.1
     tp.stock_x_len =  1.5  #2.8
     tp.remove_surface_amt = 0.01
     tp.stock_x_len = 1.5
     tp.lid_thick   = 0.18
     tp.recalc()
       
     
  print "(option =", option, ")\n" 
  if (option == 1)     
    #  This configuration is for the 3/4" styrofoam with
    #  a 2.8 inch wheel.
    tp.material_type = "foam"
    tp.wheel_type = "strong" 
    #aMill.load_bit("config/bit/carbide-0.250X0.75X2.5-6flute.rb", "Load 1/4 inch 6 floot bit", 0.5, tp.material_type)    
    aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 floot bit", 0.5, tp.material_type)    
    tp.stock_z_len = 0.749
    tp.wheel_diam = 2.8      
    tp.wheel_thick = 0.749
    bottom_plate_thick = 0.1
    tp.lid_thick = tp.stock_z_len    
    #bolt_space_from_edge = 0.35
    tp.full_recalc()    
  elsif (option == 2)
    #  This configuration is for the 0.22 acrylic
    #  with a 1.5 inch diameter wheel.     
    tp.material_type = "acrylic"
    tp.wheel_type = "strong" 
    aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 floot bit", 0.5, tp.material_type)    
    tp.stock_z_len          = 0.22
    tp.stock_x_len          = 3.5
    tp.stock_y_len          = 3.5
    tp.wheel_diam           = 1.8    
    #tp.wheel_diam          = 4.4
    tp.wheel_thick          = 0.22
    tp.wall_thick           = 0.06
    tp.floor_thick          = 0.06
    tp.lid_thick            = tp.stock_z_len
    tp.air_gap_at_bottom    = 0.02
    tp.bearing_inside_diam  = 0.24
    tp.bearing_outside_diam = 0.3743
    tp.bearing_thick        = 0.125
     # Shaft Diam can be different than bearing inside
     # diameter because the shaft is generally turned down
     # on the ends to fit the bearing so the shaft
     # holes moving from layer to layer will almost always
     # be larger than the bearing outside diameter.
    tp.shaft_diam           = 0.25  
    tp.bolt_space_from_edge = 0.2
    tp.full_recalc()
    tp.shaft_type = "D"
  elsif (option == 3)
     #  This configuration is for the 0.18 acrylic
    #  with a 1.5 inch diameter wheel.     
    tp.material_type = "acrylic"
    tp.wheel_type == "strong" 
    aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 floot bit", 0.5, tp.material_type)    
    
    
    if (sub_option == 12)
      tp.stock_z_len           = 0.430 # Acrylic
    else
      tp.stock_z_len           = 0.216 # Acrylic
      #tp.stock_z_len          = 0.25 # Aluminum
      #tp.stock_z_len          = 0.63 # Acrylic three layers thick
    end
    
    tp.stock_x_len          = 8
    tp.stock_y_len          = 5.3  
    tp.wheel_diam           = 4.4
    
    tp.wheel_thick          = 0.216
    #tp.wheel_thick          = 0.63 # Acrylic three layers thick
    
    tp.wheel_lid_thick      = 0.09
    tp.wheel_wobble_room    = 0.05 
    tp.diffuser_width       = 0.7
    tp.wall_thick           = 0.06
    tp.floor_thick          = 0.06
    tp.lid_thick            = 0.09
    tp.air_gap_at_bottom    = 0.02
    tp.bearing_inside_diam  = 0.1235
    tp.bearing_outside_diam = 0.3743
    tp.bearing_thick        = 0.125
    tp.shaft_diam           = 0.0752
    tp.bolt_space_from_edge = 0.2
    #tp.x_adj               = 1.0
    #tp.y_adj               = 0.4
    tp.volute_width_right   = tp.wheel_radius * 0.2
    tp.volute_width_left    = tp.wheel_radius * 0.5

    tp.full_recalc()
    
    tp.shaft_type = "ROUND"
  elsif (option == 4)
    #  This configuration is for the 0.56 inch UHMW 
    #  with a 1.5 inch diameter wheel.     
    tp.material_type = "uhmw"
    tp.wheel_type = "spike" 
    aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 floot bit", 0.5, tp.material_type)    
    tp.stock_z_len          = 0.56 # uhmw
    #tp.stock_z_len          = 0.25 # Aluminum
    tp.stock_x_len          = 2.02
    tp.stock_y_len          = 2.02
    tp.wheel_diam           = 1.95   
    tp.wheel_thick          = 2.02
    tp.wall_thick           = 0.1
    tp.floor_thick          = 0.1
    tp.lid_thick            = 0.22
    tp.air_gap_at_bottom    = 0.02
    tp.bearing_inside_diam  = 0.24
    tp.bearing_outside_diam = 0.3743
    tp.bearing_thick        = 0.125
    tp.shaft_diam           = 5.0 / 16.0 # 5/16 to allow threading to 3/8"  
    tp.bolt_space_from_edge = 0.2
    tp.full_recalc()
    tp.shaft_type = "ROUND"
    tp.min_wheel_clearance = 0.05
  elsif (option == 5)
     #  This configuration is for the 0.645 acrylic
    #  with a 1.5 inch diameter wheel.     
    tp.material_type = "acrylic"
    tp.wheel_type == "strong" 
    aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 floot bit", 0.5, tp.material_type)            
    if (sub_option == 14)
      #tp.stock_z_len           = 0.90   # Acrylic
      #tp.wheel_thick           = 0.90
      tp.stock_z_len           = 0.432   # Acrylic 2 layers thick
      tp.wheel_thick           = 0.432
    else
      tp.stock_z_len           = 0.216  # Acrylic
      #tp.stock_z_len          = 0.25   # Aluminum
      #tp.stock_z_len          = 0.63   # Acrylic three layers thick
      tp.wheel_thick          = 0.216
    end    
    tp.stock_x_len          = 7.0
    tp.stock_y_len          = 5.8  
    tp.wheel_diam           = 5.1     
    tp.wheel_lid_thick      = 0.09
    tp.wheel_wobble_room    = 0.05 
    tp.diffuser_width       = 0.7
    tp.wall_thick           = 0.06
    tp.floor_thick          = 0.06
    tp.lid_thick            = 0.09
    tp.air_gap_at_bottom    = 0.02
    tp.bearing_inside_diam  = 0.1235
    tp.bearing_outside_diam = 0.3743
    tp.bearing_thick        = 0.125
    tp.shaft_diam           = 0.0752
    tp.bolt_space_from_edge = 0.2
    tp.entrance_diam        = 0.60
    #tp.x_adj               = 1.0
    #tp.y_adj               = 0.4
    tp.volute_width_right   = tp.wheel_radius * 0.2
    tp.volute_width_left    = tp.wheel_radius * 0.5
    tp.shaft_type = "ROUND"
    tp.full_recalc()
  end # if option
  
      
  # Center of impeller for milling
  tbr =  aMill.bit_radius 
  impeller_cent_x = tp.wheel_radius + tbr
  impeller_cent_y = tp.wheel_radius + tbr       
        
  if (sub_option == 0)            
    tp.mill_pump_wheels() 
  elsif sub_option == "imp_strong"
       return tp.mill_strong_impeller(impeller_cent_x, impeller_cent_y)        
  elsif sub_option == "imp_small"
       return tp.mill_small_diameter_pump_wheel(impeller_cent_x, impeller_cent_y)
  elsif sub_option == "imp_spike"
       return tp.mill_simple_pump_wheel(pCent_x = impeller_cent_x, pCent_y = impeller_cent_y)
  elsif sub_option == "imp_tesla"
       return tp.mill_pump_wheel_tesla(impeller_cent_x,impeller_cent_y)     
  elsif sub_option == "imp_original"     
       return tp.mill_pump_wheel(impeller_cent_x,impeller_cent_y)
  elsif sub_option == "imp_paddle"
       return tp.mill_pump_wheel(impeller_cent_x,impeller_cent_y)     
   
  elsif (sub_option == 1)
    tp.mill_body()          
  elsif (sub_option == 2)
    # TODO:this layer can be as small thin
    # as possibl and still savely hold
    # the bearing.
    tp.mill_lid_outer()  
  elsif (sub_option == 3)
    # TODO: this layer can be as thin as
    # possible.   The nestled area is
    # generally less than 1/20th of an inch
    # and the air mixing area could be that 
    # much more so 1/10 or less could be used.
    tp.mill_layer_separator()  
  elsif (sub_option == 4)
    tp.mill_bottom_case()    
  elsif (sub_option == 5)                    
    tp.mill_side_outlet      
  elsif (sub_option == 6)                    
    # Mirror a mirror image of the
    # impellor wheel which can be
    # bonded to the main rather
    # than glueing on and lid. The
    # impeller vaynes are reversed to
    # allow it to match up.
    tp.mirror_impellor = true
    tp.mill_pump_wheels()
  
  elsif (sub_option == 7)
    print "(sub option 7 mill lid for impeller)\n"
    tp.stock_z_len = 0.08
    tp.material_type = "acrylic"
    aMill.curr_bit.adjust_speeds_by_material_type(aType=tp.material_type)   
    print "(preparing to call mill lid)\n"
    tp.stock_z_len = 0.08
    tp.mill_pump_wheel_lid(impeller_cent_x, impeller_cent_x)
    print "(finished mill_pump_wheel_lid)\n"
  elsif (sub_option == 8)   
    print "(sub option 8 mill body separator)\n"
     tp.mill_body_separator(0, tp.drill_through_depth)
  elsif (sub_option == 9)   
    tp.material_type = "acrylic"  
    tp.stock_z_len = 0.22 
    aMill.curr_bit.adjust_speeds_by_material_type(aType=tp.material_type)      
    t_cent_x = tp.impeller_hub_nut_mill_radius + tbr
    t_cent_y = tp.impeller_hub_nut_mill_radius + tbr
    tp.impeller_hub_nut(t_cent_x, t_cent_y, tp.stock_z_len)
 elsif (sub_option == 10)   
    tp.material_type = "acrylic"  
    tp.stock_z_len = 0.22 
    #tp.wall_thick *= 1.5    
    tDiam  = 2.8 #tp.wheel_diam
    aMill.curr_bit.adjust_speeds_by_material_type(aType=tp.material_type)      
    tp.mill.cut_inc = tp.mill.cut_inc * 2.0
    t_cent_x = (tDiam / 2.0) + tbr
    t_cent_y = (tDiam / 2.0)+ tbr           
    tp.impeller_radial(pCent_x = t_cent_x, 
      pCent_y    = t_cent_y, 
      pDiam      = tDiam, 
      pNumFins   = 10, #4, 
      pRimThick  = 0.125 / 2.0, #0.250, 
      pHubDiam   = (tp.hub_diam + tp.mill.bit_diam) * 1.7,  
      pShaftDiam = tp.shaft_diam, 
      pThick     = tp.stock_z_len)               
  elsif (sub_option == 11)  
    print "(sub option 11 mill lid for strong impeller)\n"
    tp.stock_z_len = 0.08
    tp.material_type = "acrylic"
    aMill.curr_bit.adjust_speeds_by_material_type(aType=tp.material_type)   
    print "(preparing to call mill lid)\n"
    tp.stock_z_len = 0.08
    tp.mill_strong_impeller_lid(impeller_cent_x, impeller_cent_x)
    print "(finished mill_pump_wheel_lid)\n"
  elsif (sub_option == 12)  
    print "(sub option 12 body and infuser for strong impeller)\n"        
    tp.stock_z_len = 0.08
    tp.mill_diffuser_body(pBegZ = 0, 
       pEndZ = tp.stock_z_len)
    print "(finished mill_difusser_body)\n" 
  elsif (sub_option == 13)  
    print "(sub option 13 lid for infuser body)\n"        
    tp.stock_z_len = 0.22
    tp.mill_diffuser_lid(pBegZ = 0,  pEndZ = tp.stock_z_len)
    print "(finished mill_difusser_body)\n"  
  elsif (sub_option == 14)  
 
    print "(sub option 14 paddle type impeller. )\n"            
    tp.mill_paddle_impeller(impeller_cent_x, impeller_cent_y)
        print "(finished paddle type impeller)\n"    
  elsif (sub_option == 15)  
    print "(sub option 15 paddle type impeller lid)\n"        
    tp.stock_z_len = 0.082
    tp.mill_paddle_impeller_lid(
            impeller_cent_x, 
            impeller_cent_x, 
            pBegZ = 0,  
            pEndZ = 0 - tp.stock_z_len.abs)
    print "(finished paddle type impeller)\n"
    
  elsif (sub_option == 16)
    print "(sub option 16 body area and lid combination for paddle wheel )\n"
    tp.stock_z_len = 0.22
    tp.mill_paddle_body_lid(
      pCent_x = 4, 
      pCent_y = 3.5, 
      pBegZ = 0, 
      pEndZ = 0 - tp. stock_z_len.abs)     
  end # if sub option

  
  tp.mill.job_finish()

    
end # main method  





main = true
if main == true
  # o1 = 3
  o1 = 5  # 4.8" diameter wheel default 0.66 inches thick  
  #o2 = "imp_strong"
  #o2 = 11 # strong impeller lid
  #o2 = 12 # diffuser body
  #o2 = 13 # diffuser body lid
  o2  = 14 # Paddle type wheel
  #o2  = 15 # paddle type wheel lid
  #o2   = 16 # paddle bottom mill air entrance and bearing support
  main_pump_centrifuge(o1,o2) 

   ## Items with ## are not yet implemented    
   #  1,x =  Foam 2.4 inch wheel
   #  2,x =  Acrylic 1.9 inch wheel by .18 thick
   
   #  3,x =  Acrylic or Aluminum 4.4 inch wheel 0.22 
   #    or 0.25 thick designed for housing with 5.1 inches
   #     in Y dimension with outer diffuser 0.3 inches 
   #     wide and 0.1 inch thick walls.  The limit on 
   #     the mill is 5.5 inches which makes
   #         this the largest we can make.
   #     uses 0.0625 shaft for direct motor mounting.
   
   #   
   # 4,x = UHMW,  0.56" thick,  2.02 wide. Milling 1.95 inch wheel
   
   # 5,x =  Sames as 3,X but assumes a impeller that is  0.63 inches thick and 4.4 inches in diameter. 
   
   #x, "imp_strong" - Mills impeller which optimizes 
   #        wheel strength.
   #x, "imp_small"  - Mills impeller which is optimized
   #         for reasonable performance at small sizes.
   #x, "imp_spike"  - Mills impeller modeled on blower 
   #          wheels shich leaves a series of isolated
   #          Islands standing up separated by air space
   #          seems to be highly efficient but only good
   #          for materials with very high tinsel strenght.
   #x,  "imp_tesla" - Mills impeller wheel for use in 
   #          tesla pump.  This is a thin flat which with
   #          star type washer in the center with wings or
   #          other profusions along edge.  Optimized for
   #          using adheasion and coheasion as primary 
   #          physics.  Highly resistant to erosion.
   #          Normally
   #          used in sets of 6 or more.
   #x, "imp_original - A good effeciency implementation that
   #          seems to take a long time to mill. Good air 
   #          mixing area and good balance but has a 
    #         weak area at end of center spokes.
   #  ##imp_paddle - A centrifuge impeller which uses a 
   #           series of straight lines emanating from
   #           center of wheel to outer edge.  Similar
   #           to design for most small and cheap fans
   #           and cheap vacuumes.  This one would be easy
   #           to mold.
   #  ##imp_paddle_slot - A centrifuge impeller with slots
   #    for installation of 0.22" blades used to save 
   #    material and produce taller wheels without wasing
   #    large amounts of material between the paddle fins.
   #               
   # 1,0 = mills the impeller wheel
   # 1,1 = mill  the body and volute layer
   # 1,2 = mills the top lid to fit the body  
   # 1,3 = mills the layer separator   
   # 1,4 = mill the bottom plate
   # 1,5 = mill axel to fit current specs.
   # 1,6 = mill mirror image of the simple impeller wheel
   # 1,7 = mill positive image of wheel to use as lid
   # 1,8 = mill body separator
   # 1,9 = mill impeller hub nut for threading which has radial fan
   # 1,11= mill lid for strong impeller
   #`1,10 = mill radial fan that is the size of our wheel
   #        + an area for the sideways difusser.
   # 1,12 = Diffuser and basic pump body 
   ## 1,25 = mill mold for impeller plate
   ## 1,26 = mill mold for top lid
   ## 1,27 = mill mold for layer separator
   ## 1,28 = mill mold for bottom place
   
  
  
end #if

