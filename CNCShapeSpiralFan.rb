# cncShapeSpiralFan.rb
#
require 'cncMill'
require 'cncGeometry'
require 'cncShapeBase'
require 'cncShapeArc'
require 'cncShapeSpiral'
require 'cncShapeSpiralFan'
require 'cncShapeCircle'

#  Calculate the largest degree of increment
#  that will yeild a move less max_move. 
#  this function is designed to allow
#  us to calcualte the amount of degree movement
#  when face milling a arc and then stepping over
#  to the next arc for a pocket.
#   #   #   #   #   #   #   #   #   #


#  do the fan pocket milling using the
#  current cutting depth in slices until
#  we reach the required depth.
# # # # # # # # # # # # # # # # # # # 
#def mill_fan_pocket(mill, cent_x, cent_y, in_diam,in_beg_deg, in_end_deg,  out_diam,  out_beg_deg, out_end_deg, pBeg_z, pEnd_z,    bit_adjust = true)
# # # # # # # # # # # # # # # # # # # 
#  if (pBeg_z > 0)
#    pBeg_z = 0 - pBeg_z
#  end
#  if (pEnd_z > 0)
#    pEnd_z = 0 - pEnd_z
#  end
    
#  mill_fan_pocket_s(mill, cent_x, cent_y, in_diam,in_beg_deg, in_end_deg,  out_diam,  out_beg_deg, out_end_deg, pBeg_z, pEnd_z,  bit_adjust)
       
#  end #meth

  
  

# # # # # # # # # # # # # # # # # # # 
def mill_fan_pocket(mill, cent_x, cent_y, in_radius,in_beg_deg, in_end_deg,  out_radius,  out_beg_deg, out_end_deg, pBeg_z, pEnd_z,  bit_adjust = false, auto_retract=true, mill_outer_edge=false)
# # # # # # # # # # # # # # # # # # # 
  # start as center and 
 
  #print "(mill_fan_pocket_s  cent_x=", cent_x,  " cent_y=", cent_y,  "  in_radius=", in_radius,   " in_beg_deg=", in_beg_deg, " in_end_deg=", in_end_deg, "  out_radius=", out_radius,  "  out_beg_deg=", out_beg_deg,  "  out_end_deg=", out_end_deg,  "  pBeg_z = ", pBeg_z, "pEndZ=", pEnd_z,  "  bit_adjust=",  bit_adjust,  "  auto_retract=",  auto_retract, ")\n"
  
  if (pBeg_z > 0)
    pBeg_z = 0 - pBeg_z
  end
  if (pEnd_z > 0)
    pEnd_z = 0 - pEnd_z
  end
  
  if (in_end_deg < in_beg_deg)
    in_end_deg = in_beg_deg
  end
  
  if (out_end_deg < out_beg_deg)
    out_end_deg = out_beg_deg
  end
  
  cent_x += 0.0
  cent_y += 0.0
  
  if (bit_adjust == true)
    in_radius  += mill.bit_diam
    out_radius -= mill.bit_radius
  end 
  if (in_radius > out_radius)
    out_radius = in_radius
  end
    
  pass_inc = degrees_for_distance(out_radius, mill.cut_inc*2.0)
  
  curr_in_deg  = in_beg_deg
  curr_out_deg = out_beg_deg
  last_in_deg  = -99
  cnt = 0
  
  tSpeed = mill.speed()
  tCutDepthInc = mill.cut_depth_inc()
  tPlungSpeed  = mill.plung_speed()
  mill.set_speed(tSpeed * 0.8)
  mill.set_cut_depth_inc(tCutDepthInc * 0.8)
  mill.set_plung_speed(tPlungSpeed * 0.5)
  while (true)
    cnt += 1
    
    arc_to_radius(mill,  cent_x,  cent_y,  in_radius,     
      curr_in_deg, out_radius,  curr_out_deg,
        pBeg_z, pEnd_z)
       
    mill.set_speed(tSpeed * 1.8)
    mill.set_cut_depth_inc(tCutDepthInc * 1.0)  
    mill.set_plung_speed(tPlungSpeed)

             
    if (curr_in_deg == in_end_deg) && (curr_out_deg == out_end_deg)
       break
    else    
      curr_in_deg += (pass_inc * 0.3)
      curr_out_deg += pass_inc
      if (curr_out_deg >  out_end_deg)
        curr_out_deg = out_end_deg
      end
      if (curr_in_deg > in_end_deg)
        curr_in_deg = in_end_deg
      end      
    end #else        
  end # while 
  
  if (mill_outer_edge == true)
    arc_radius(mill,  cent_x,  cent_y,  out_radius,     
        out_beg_deg, out_end_deg,
          pBeg_z, pEnd_z)
  end
  
  mill.set_speed(tSpeed)
  mill.set_cut_depth_inc(tCutDepthInc)
  mill.set_plung_speed(tPlungSpeed)
  if (auto_retract == true)
    mill.retract()
  end
  

end # meth




 #   #   #   #   #   #   #   #   #
 #  Mill out the air entrance holes
 #  for a variety of different kinds of 
 #  wheels
 #   #   #   #   #   #   #   #   #
 def mill_out_air_entrance(mill, pCent_x, pCent_y, pMin_radius, pMax_radius, pNum_holes, pBeg_z, pEnd_z, pSpoke_angle, pSpoke_width=0.1)
    #   #   #   #   #   #   #   #   #
    # Mill out center holes as large as possible
    # without comprimising strength
    #   #   #   #   #   #   #   #   #    
    degrees_per_hole = 360 / pNum_holes
    
    
    pMin_radius += mill.bit_radius
    pMax_radius -= mill.bit_radius
    
    if (pMax_radius < pMin_radius)
      pMax_radius = pMin_radius
    end
    
    
    #print "(pNum_holes=", pNum_holes, ")\n"
    #print "(degrees_per_hole=", degrees_per_hole, ")\n"
    #print "(pMin_radius=", pMin_radius, ")\n"
    #print "( pMax_radius=", pMax_radius, "\n"
    
    bit_radius_degree_inner = degrees_for_distance(pMin_radius,  mill.bit_radius)
    
      bit_radius_degree_outer = degrees_for_distance(pMax_radius,  mill.bit_radius)
    
    inner_bit_and_spoke_degree = degrees_for_distance(pMin_radius,  (mill.bit_radius * 2 + pSpoke_width))
    outer_bit_and_spoke_degree = degrees_for_distance(pMax_radius,  (mill.bit_radius * 3 + pSpoke_width))* 1.05
    
    usable_inner_degrees =   degrees_per_hole - inner_bit_and_spoke_degree
    #print "(inner_bit_and_spoke_degree=", inner_bit_and_spoke_degree, ")\n"
    #print "(usable_inner_degrees=", usable_inner_degrees, ")\n"
    
    if (usable_inner_degrees < 0)
      usable_inner_degrees = 0
    end
  
    usable_outer_degree = degrees_per_hole -  outer_bit_and_spoke_degree
    #print "(outer_bit_and_spoke_degree=", outer_bit_and_spoke_degree, ")\n"
    #print "(usable_outer_degree=", usable_outer_degree, ")\n"

    if (usable_outer_degree < 0)
       usable_outer_degree = 0
    end
    
    if (usable_inner_degrees < 0)
      usable_inner_degrees = 0
    end
    
    #print "(inner_bit_and_spoke_degree=", inner_bit_and_spoke_degree, ")\n"
     
    
    beg_degree = 0
    for hole_num in (1..pNum_holes)
      mill.retract()
             
    
       end_inner_degree = (beg_degree + usable_inner_degrees)
       
       end_out_degree = (beg_degree + usable_outer_degree + pSpoke_angle)
       
       #print "(beg_degree =", beg_degree, " end_inner_degree = ", end_inner_degree, "  end_out_degree=", end_out_degree, ")\n"
       
       mill_fan_pocket(mill = aMill,
         cent_x = pCent_x,
         cent_y = pCent_y,
         in_radius = pMin_radius,
         in_beg_deg=beg_degree + bit_radius_degree_inner, 
         in_end_deg=end_inner_degree, 
         out_raius=pMax_radius,
         out_beg_deg=beg_degree + pSpoke_angle + bit_radius_degree_inner,
         out_end_deg=end_out_degree, 
         pBeg_z = 0,
         pEnd_z= pEnd_z)            
         
       aMill.retract()          
                                                                    
      beg_degree += degrees_per_hole 
       
     end #for
     aMill.retract() 
   end #def method
       
     
     
main = false 
     
if (main == true)
  
  aMill = CNCMill.new
  
  aMill.job_start()
  aMill.home
  #aMill.retract_depth = 0.1
  aMill.home
  aBit = aMill.current_bit
  
  bit2 = CNCBit.new(aMill, "config/bit/carbide-0.125X0.5X1.5-4flute.rb")
  
  #bit2 = CNCBit.new(aMill, "config/bit/carbide-0.250X0.75X2.5-6flute.rb")
  
  aMill.curr_bit = bit2
  bit2.recalc()
  print "(calculated fspeed=", aMill.curr_bit.get_fspeed(), ")\n"
  
  
  # TODO:  Calculate speed and cutting increment we can use 
  #  with Aluminum
  
  aMill.pause("Please put in X-Power 0.30  5/16 carbide bit")
  
  if (1 == 1)
     lout_diam = 1.45
     lhub_diam  = 0.60
     lshaft_diam = 0.23
     lcx = lout_diam / 2.0 + 0.02
     lcy = lout_diam / 2.0 + 0.02
     
     lmaterial_thick = 0.5
     lblade_depth    = (lmaterial_thick - 0.15) 
     lbase_thick     = lmaterial_thick - lblade_depth
     
     
      aMill.retract()  
   
          
     aCircle = CNCShapeCircle.new(aMill)
     
            
     aMill.retract()
      
     # Outline of the wheel size to 
     # more readily show how things
     # will look when finished.
       spiral_down_circle(aMill, lcx, lcy, 
          lout_diam + aMill.bit_radius * 4, 
          0,
          0 - (lblade_depth / 20), 
          false)
          
            
           
     aMill.retract
     # Mill hole in support block to accept the 
     # anchor bolt.
     if (1 == 1) 
     aCircle.beg_depth = 0.05
     aCircle.mill_pocket(lcx, lcy, lshaft_diam, 
         0 - lblade_depth ,  
         island_diam=0)
     
     aMill.retract
     end #if
      
       
  
     # Pause for inserting bolt holder
     
     
       #aCircle.mill_pocket(
       # x = cx,
       # y = cy,
       # diam = 1.6,
       # depth = 0 - material_thick,
       # island_diam=1.5)
  
     
     #  Mill out the wholes between the blades
     beg_deg = 0.0
       #  Mill out the actual Fan Blades
     beg_deg = 0.0
     while beg_deg < 360
     
         
       aMill.retract 
         
       #aMill.retract
       mill_fan_pocket(mill = aMill, 
         cent_x = lcx, 
         cent_y = lcy, 
         in_diam = 0.799,  
         in_beg_deg=beg_deg + 19, 
         in_end_deg=beg_deg + 35, 
         out_diam=lout_diam,  
         out_beg_deg=beg_deg + 95.0, 
         out_end_deg=beg_deg + 135.0, 
         depth = 0 - lblade_depth)
         aMill.retract 
         mill_fan_pocket(mill = aMill, 
         cent_x = lcx, 
         cent_y = lcy, 
         in_diam = 0.55,  
         in_beg_deg=beg_deg, 
         in_end_deg=beg_deg + 5, 
         out_diam=0.75,  
         out_beg_deg=beg_deg + 20, 
         out_end_deg=beg_deg + 25, 
         0,
         depth = 0 - lmaterial_thick + 0.15)
  
         #mill_fan_pocket(mill, cent_x, cent_y, in_diam,in_beg_deg, in_end_deg,  out_diam,  out_beg_deg, out_end_deg, pBeg_z, pEnd_z,    bit_adjust = true
         
         
       beg_deg += 120
       
     end #while
     
    
     aMill.retract   
     spiral_down_circle(aMill, lcx, lcy, 
          lout_diam + aMill.bit_radius * 4, 
          0,
          0 - lmaterial_thick, 
          false)
  
     
  end #if
  
  
  # Now mill a Arch pocket from senter area to external rim.
  # Then repeat it working around the wheel.  Need to have it
  # come out with an even number.
  if (1 == 0)
   aRes = arc_segment_pocket(
       mill = aMill, 
       circ_x  = 1.0,
       circ_y  = 1.0,
       min_radius = 0.45,
       max_radius = 1.5,
       beg_angle  = 41.0,
       end_angle  = 48.3,
       0,
       depth      = -1.8,
       degree_inc = 0.5)
  end
  
  
  
  if (1 == 0)
   mill_spiral(
    mill = aMill,
    cent_x = 1.0,
    cent_y = 1.0,
    inner_diam = 0.45,
    outer_diam = 1.4,
    channel_thick = 0.2,
    wall_thick = 0.25,
    depth  = -0.5)
  end #if     
       
  # TODO:  Mill out the center whole for axle support.
  
  # TODO:  Stop for mounting bold.
  
  # TODO:  Mill out air escape section in center of
  #        each wheel.
  
  
  # TODO:  Mill out the cutout for the round wheel.

end # if main