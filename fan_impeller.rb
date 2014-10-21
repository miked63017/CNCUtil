# Fan impeller 
require 'cncMill'
require 'cncGeometry'
require 'cncShapeBase'
require 'cncShapeArc'
require 'cncShapeSpiral'
require 'cncShapeCircle'
require 'cncShapeRect'
require 'cncShapeArcPocket'
require 'cncShapeArcPocketAdv'


def mill_fan_blade(mill, cent_x, cent_y, shaft_diam, hub_diam,  outside_diam,   material_thick, num_blades, fin_width)
     drill_through = 0 - (material_thick + 0.02)
     max_depth     = drill_through - 0.05     
     hub_radius    = (hub_diam / 2.0) + mill.bit_radius
     wheel_radius  = outside_diam / 20.0
     air_diam      = (hub_diam + outside_diam) / 2.0
     air_radius    = air_diam / 2.0
     radius_delta  = wheel_radius - air_radius
     num_bit_passes_in_radius = radius_delta / mill.cut_inc     
     degrees_for_bit_inner    = degrees_for_distance(hub_radius,  mill.bit_radius)
     degrees_for_bit_outer    = degrees_for_distance(wheel_radius, mill.bit_radius)     
     degrees_for_fin_inner    = degrees_for_distance(hub_radius, fin_width)     
     degrees_for_fin_outer    = degrees_for_distance(wheel_radius, fin_width)     
     fan_blade_total_space    = (360.0 / num_blades.to_i)                    
     blade_no = 0
     curr_blade_deg = 0
	 curr_blade_end = 0  # TODO: Check to see if this is the right default end.
     curr_depth = 0     

     while blade_no < num_blades
       #arc_to_radius(mill,  cent_x,  cent_y,  in_radius,     
       #curr_in_deg, out_radius,  curr_out_deg,
       #  pBeg_z, pEnd_z)        
       curr_depth -= mill.cut_depth_inc     
       slot_beg_inner =  curr_blade_deg + degrees_for_bit_inner
       slot_beg_outer =  curr_blade_deg + degrees_for_bit_outer
       slot_end_inner = (curr_blade_deg + fan_blade_total_space) - (degrees_for_bit_inner + degrees_for_fin_inner)
       slot_end_outer = (curr_blade_end + fan_blade_total_space) - (degrees_for_bit_outer + degrees_for_fin_outer)
       slot_diff      = slot_end_outer - slot_beg_outer
       slot_change    = slot_diff / mill.cut_inc
       num_slices     = slot_change / degrees_for_bit_outer
       deg_inc_inner  = slot_change / num_slices
      
        
       changing_radius_curve(mill, 
             pcx          = cent_x,
             pcy          = cent_y,
             pBeg_radius  = hub_radius, 
             pBeg_angle   = slot_beg_inner,  
             pBeg_z       = curr_depth, 
             pEnd_radius  = wheel_radius,
             pEnd_angle   = slot_beg_outer, 
             pEnd_z       = curr_depth,  
             pDegrees_per_step = 0.1,
             pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=false)
          
       changing_radius_curve(mill, 
             pcx          = cent_x,
             pcy          = cent_y,
             pBeg_radius  = hub_radius, 
             pBeg_angle   = slot_end_inner,  
             pBeg_z       = curr_depth, 
             pEnd_radius  = wheel_radius,
             pEnd_angle   = slot_end_outer, 
             pEnd_z       = curr_depth,  
             pDegrees_per_step = 0.1,
             pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=false)
    
       changing_radius_curve(mill, 
             pcx          = cent_x,
             pcy          = cent_y,
             pBeg_radius  = hub_radius, 
             pBeg_angle   = slot_beg_inner,  
             pBeg_z       = curr_depth, 
             pEnd_radius  = hub_radius,
             pEnd_angle   = slot_beg_outer, 
             pEnd_z       = curr_depth,  
             pDegrees_per_step = 0.1,
             pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=false)
    
                 
       curr_radius =  hub_radius
       curr_end = slot_end_inner
       while (curr_radius < wheel_radius)
          # Mill out the area
          # in between
          changing_radius_curve(mill, 
             pcx          = cent_x,
             pcy          = cent_y,
             pBeg_radius  = hub_radius, 
             pBeg_angle   = slot_end_inner,  
             pBeg_z       = curr_depth, 
             pEnd_radius  = wheel_radius,
             pEnd_angle   = slot_end_outer, 
             pEnd_z       = curr_depth,  
             pDegrees_per_step = 0.1,
             pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=false)    
             
          curr_radius += mill.bit_diam * 0.9
       end
         
              
       curr_blade_deg += fan_blade_total_space
       blade_no += 1
     end # blades
     

end


aMill  =  CNCMill.new
aMill.job_start()
mill_fan_blade(aMill, cent_x=3 , cent_y=3, shaft_diam=0.062, hub_diam=0.3,  outside_diam=3,   material_thick=0.45, num_blades=8, fin_width=0.1)
aMill.retract
aMill.home()
aMill.job_finish()
 