# cncShapeCircle.rb
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

require 'cncMill'
require 'cncBit'
require 'cncMaterial'
require 'cncGeometry'
require 'cncShapeArc'
require 'cncShapeCircle'



#  A utility for producing keyed shaft for
#  a keyed D.  That is a shaft with one
#  side flattened like it is on some motors.
#  Joe intendes to use this to eliminate the need
#  for threading on the Tesla wheels.    
#
#  NOTE:  This could change the weight balance just a little
#    if we encounter a balancing problem then we should
#    consider flattening the other side to compensate.
# - - - - - - - - - - - - - - - - - -
def mill_DShaft(mill, lx,ly, diam, beg_z=@cz, end_z=@cz, adjust_for_bit_radius=true, mirrored = false)
# - - - - - - - - - - - - - - - - - -
    cradius = diam / 2.0
     # If we need to adjust for radius then we subtract our
     # bit radius from our circle diameter prior to milling the
     # arc segments.
     print "(mill_DShaft diam=", diam, " adjust_for_bit_radius=",adjust_for_bit_radius, ")\n" 
     print "(mill.bit_radius=", mill.bit_radius, ")\n"
     if (adjust_for_bit_radius == true)
       cradius -= mill.bit_radius
     end #if
     
     if (cradius < 0)
       print "(DSHAFT WARNING cradius ", cradius, " is less than 0 bit radius=", mill.bit_radius, ")\n"
       return
     end
     
     print "(cradius after adjust=", cradius, ")\n"
    
     if (beg_z > 0)
       beg_z = 0 - beg_z
     end
     
     if (end_z > 0)
       end_z = 0 - end_z
     end
     

     curr_depth = beg_z
     next_depth = curr_depth - mill.cut_depth_inc
     if (next_depth < end_z)
       next_depth = end_z
     end
     
     # TODO:  Need to calculate these based
     # on the amount of flat we want.  Based
     # on the current bit size.   
     end_deg = 290
     beg_deg = 70
     
     
      
     while(true)      # depth 
       mill.move(lx,ly)
       #print "(curr_depth=", curr_depth, ")\n"
       
       if (mill.bit_radius < cradius)
         curr_radius = mill.bit_radius 
       else
         curr_radius = cradius
       end
       
       next_depth = curr_depth - mill.cut_depth_inc
       if (next_depth < end_z)
         next_depth = end_z
       end
       
       ppc = 0 
       while(true) 
         if (curr_radius > cradius)
           curr_radius = cradius
         end
         ppc += 1
         if (curr_depth == end_z)
           deg_per_step = 1
         else
           deg_per_step = 15
         end
         
         
         
         print "(curr_radius=", curr_radius, ")\n"      
         bcp = calc_point_from_angle(
                  cx=lx,
                  cy=ly, 
                  angle=beg_deg, 
                  length=curr_radius)
     
         ecp = calc_point_from_angle(
                  cx=lx,
                  cy=ly, 
                  angle=end_deg, 
                  length=curr_radius)
     
        if (mirrored==true)
          bcp.y = vmirror(bcp.y)
          ecp.y = vmirror(ecp.y)
        end
                  
        if (mill.cz > 0)
          mill.move_fast(bcp.x, bcp.y)
          mill.move_fast(bcp.x, bcp.y, 0)
        end
                     
        mill.move(bcp.x, bcp.y)                   
        #mill.plung(curr_depth)
        
        if (ppc == 1)
          cdd = curr_depth
        else
          cdd = next_depth
        end
        
        #changing_radius_curve(mill, pcx, pcy, pBeg_radius, pBeg_angle,  pBeg_z,  pEnd_radius, pEnd_angle, pEnd_z,  pDegrees_per_step=0.5, pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=true)
        
        print "(deg_per_step=", deg_per_step, ")\n"
        
        tBeg_deg = beg_deg
        tEnd_deg = end_deg
        tly = ly
        if (mirrored == true)
          tBeg_deg = tBeg_deg + 180
          tEnd_deg = tEnd_deg + 180
          tly      = vmirror(tly)
        end
        
        print "(curr_radius=", curr_radius, ")\n"
        changing_radius_curve(mill, lx, tly, curr_radius, tBeg_deg,  cdd,  curr_radius, tEnd_deg, next_depth,  deg_per_step, nil, nil, false)
       
                 
         mill.move(ecp.x, ecp.y)
         mill.move(bcp.x, bcp.y)
         
         if (curr_radius == cradius)
           break
         else
           curr_radius += mill.cut_inc 
           if (curr_radius > cradius)
             curr_radius = cradius
           end
         end #else
       end # while radius
              
     if (curr_depth == end_z)
       break
     else
       curr_depth -= mill.cut_depth_inc
       if (curr_depth < end_z)
         curr_depth = end_z
       end
     end # else
     mill.move(lx,ly)
   end # while depth
     
     

end #meth
   



#  A utility for producing keyed shaft for
#  a keyed D.  That is a shaft with one
#  side flattened like it is on some motors.
#  Joe intendes to use this to eliminate the need
#  for threading on the Tesla wheels.    
#
#  NOTE:  This could change the weight balance just a little
#    if we encounter a balancing problem then we should
#    consider flattening the other side to compensate.
# - - - - - - - - - - - - - - - - - -
def mill_DDShaft(mill, lx,ly, diam, beg_z=@cz, end_z=@cz, adjust_for_bit_radius=true)
# - - - - - - - - - - - - - - - - - -
    cradius = diam / 2.0
     # If we need to adjust for radius then we subtract our
     # bit radius from our circle diameter prior to milling the
     # arc segments.
     print "(mill_DShaft diam=", diam, " adjust_for_bit_radius=",adjust_for_bit_radius, ")\n" 
     print "(mill.bit_radius=", mill.bit_radius, ")\n"
     if (adjust_for_bit_radius == true)
       cradius -= mill.bit_radius
     end #if
     
     if (cradius < 0)
       print "(DSHAFT WARNING cradius ", cradius, " is less than 0 bit radius=", mill.bit_radius, ")\n"
       return
     end
     
     print "(cradius after adjust=", cradius, ")\n"
    
     if (beg_z > 0)
       beg_z = 0 - beg_z
     end
     
     if (end_z > 0)
       end_z = 0 - end_z
     end
     

     curr_depth = beg_z
     next_depth = curr_depth - mill.cut_depth_inc
     if (next_depth < end_z)
       next_depth = end_z
     end
     
     # TODO:  Need to calculate these based
     # on the amount of flat we want.  Based
     # on the current bit size.   
     flat_sweep = 145
     flat_beg_1 = 0
     flat_beg_2 = 180
     flat_end_1 = flat_beg_1 + flat_sweep
     flat_end_2 = flat_beg_2 + flat_sweep
     
     
      
     while(true)      # depth 
       mill.move(lx,ly)
       #print "(curr_depth=", curr_depth, ")\n"
       
       if (mill.bit_radius < cradius)
         curr_radius = mill.bit_radius 
       else
         curr_radius = cradius
       end
       
       next_depth = curr_depth - mill.cut_depth_inc
       if (next_depth < end_z)
         next_depth = end_z
       end
       
       ppc = 0 
       while(true) 
         if (curr_radius > cradius)
           curr_radius = cradius
         end
         ppc += 1
         if (curr_depth == end_z)
           deg_per_step = 1
         else
           deg_per_step = 15
         end
         
         print "(curr_radius=", curr_radius, ")\n"      
         bcp = calc_point_from_angle(
                  cx=lx,
                  cy=ly, 
                  angle=flat_beg_1, 
                  length=curr_radius)
     
         ecp = calc_point_from_angle(
                  cx=lx,
                  cy=ly, 
                  angle=flat_end_1, 
                  length=curr_radius)
      
         bcp2 = calc_point_from_angle(
                  cx=lx,
                  cy=ly, 
                  angle=flat_beg_2, 
                  length=curr_radius)
     
         ecp2 = calc_point_from_angle(
                  cx = lx,
                  cy = ly, 
                  angle = flat_end_2, 
                  length = curr_radius)
                  
        if (mill.cz > 0)
          mill.move_fast(bcp.x, bcp.y)
          mill.move_fast(bcp.x, bcp.y, 0)
        end
                     
        mill.move(bcp.x, bcp.y)                   
        #mill.plung(curr_depth)
        mill.move(ecp.x, ecp.y)
        
        if (ppc == 1)
          cdd = curr_depth
        else
          cdd = next_depth
        end
        
        #changing_radius_curve(mill, pcx, pcy, pBeg_radius, pBeg_angle,  pBeg_z,  pEnd_radius, pEnd_angle, pEnd_z,  pDegrees_per_step=0.5, pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=true)
        
        print "(deg_per_step=", deg_per_step, ")\n"
        
        print "(curr_radius=", curr_radius, ")\n"
        changing_radius_curve(mill, lx, ly, curr_radius, flat_end_1,  cdd,  curr_radius, flat_beg_2, next_depth,  deg_per_step, nil, nil, false)
       
         
        
         
         mill.move(bcp2.x, bcp2.y)
         mill.move(ecp2.x, ecp2.y)

         changing_radius_curve(mill, lx, ly, curr_radius, flat_end_2,  cdd,  curr_radius, 360 - flat_beg_1, next_depth,  deg_per_step, nil, nil, false)         
         
         if (curr_radius == cradius)
           break
         else
           curr_radius += mill.cut_inc 
           if (curr_radius > cradius)
             curr_radius = cradius
           end
         end #else
       end # while radius
              
     if (curr_depth == end_z)
       break
     else
       curr_depth -= mill.cut_depth_inc
       if (curr_depth < end_z)
         curr_depth = end_z
       end
     end # else
     mill.move(lx,ly)
   end # while depth
     
     

end #meth


if (1 == 0)
   aMill = CNCMill.new
   aMill.job_start()
   aMill.home
   aBit = aMill.current_bit
   bit2 = CNCBit.new(aMill, "config/bit/carbide-0.125X0.5X1.5-4flute.rb")
   #bit2 = CNCBit.new(aMill, "config/bit/carbide-0.250X0.75X2.5-6flute.rb")
   aMill.curr_bit = bit2
   bit2.recalc()
   
   hole_size = 0.25
   cent_x = (hole_size / 2) + 0.1
   cent_y = cent_x
   
   mill_DShaft(aMill, x = cent_x,y=cent_y, diam=hole_size, beg_z= 0.0, end_z= -0.2, adjust_for_bit_radius=true)
   
   aMill.job_finish()
   
 end #if
   