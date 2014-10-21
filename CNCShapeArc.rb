# CNCChapeArc
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'CNCMill'
require 'CNCBit'
require 'CNCMaterial'
require 'CNCShapeBase'
require 'CNCGeometry'



# - - - - - - - - - - - - - - - - - - - -
def calculate_extent(pBeg_angle, pBeg_radius, pEnd_angle, pEnd_radius)
# - - - - - - - - - - - - - - - - - - - -
  # have to calculate ppoints to allow
  # us to make decisions containment
  mid_deg    = (pBeg_angle  + pEnd_angle ) / 2
  mid_pRadius= (pBeg_radius + pEnd_radius) / 2
  pt_mid1 =  calc_point_from_angle(pCirc_x,pCirc_y, mid_deg, pBeg_radius)
  pt_mid2 =  calc_point_from_angle(pCirc_x,pCirc_y, mid_deg, pBeg_radius)
  pt_end  = calc_point_from_angle(pCirc_x,pCirc_y, pEnd_angle, pEnd_angle)
  
  max_x = max(pt_begin.x, pt_end.x, pt_mid1.x, pt_mid2.x, pt_end.x)
  min_x = min(pt_begin.x, pt_end.x, pt_mid1.x, pt_mid2.x, pt_end.x)
  max_y = max(pt_begin.y, pt_end.y, pt_mid1.y, pt_mid2.y, pt_end.y)
  min_y = min(pt_begin.y, pt_end.y, pt_mid1.y, pt_mid2.x, pt_end.x)
 
  # NEED NEW DATA STRUCTURE
  # CNC extent that can be returned
  # as part of this function
  return nil
end #meth




   # PRIMITIVE: mill a arc from the current location to the 
   #  destination location.    Normally will only support
   #  1/4 of a circle or less.   Caller must pre-position
   #  bit and set pDepth
   # does not properly handle multiple passes
   # for deep cuts.  If multiple passes are
   # needed use the CNCShapeObject.
   # - - - - - - - - - - - - - - - - - -
   def mill_arc(mill, pxi,pyi,pRadius, pSpeed=nil,  pDirection = "G03")
   # - - - - - - - - - - - - - - - - - -
     if (pSpeed == nil)
      pSpeed = mill.speed
     elsif (pSpeed == "G03") || (pSpeed == "G02")
       # allows us to keep old functions
       # that where not passing pSpeed working
       pDirection = pSpeed
       pSpeed = mill.speed
     end #if


     cp = mill.apply_limits(pxi,pyi)
       # Adjust our X,Y coordinates to fit
       # inside our machines currently defined
       # limits.

     opcode = "G03"
     if (pDirection == "G02") || (pDirection == "clockwise")
       opcode = "G02"
     end

   

     print opcode, " X", sprintf("%8.4f", cp.x), " Y",sprintf("%8.4f", cp.y) ,  " R",sprintf("%8.4f", pRadius) ,  " F",  sprintf("%4.1f",pSpeed), "\n"
    @pcy = pyi
    @pcx = pxi
   end #meth


   # PRIMITIVE: mill a arc from the current location to the 
   #  destination location.    Normally will only support
   #  1/4 of a circle or less.   Caller must pre-position
   #  bit and set pDepth
   # does not properly handle multiple passes
   # for deep cuts.  If multiple passes are
   # needed use the CNCShapeObject.
   # - - - - - - - - - - - - - - - - - -
   def mill_arc_d(mill, pxi,pyi,pRadius, pBeg_z, pEnd_z, pSpeed=nil,  pDirection = "G03")
   # - - - - - - - - - - - - - - - - - -
     if (pSpeed == nil)
      pSpeed = mill.speed
     elsif (pSpeed == "G03") || (pSpeed == "G02")
       # allows us to keep old functions
       # that where not passing pSpeed working
       pDirection = pSpeed
       pSpeed = mill.speed
     end #if


     cp = mill.apply_limits(pxi,pyi)
       # Adjust our X,Y coordinates to fit
       # inside our machines currently defined
       # limits.

     opcode = "G03"
     if (pDirection == "G02") || (pDirection == "clockwise")
       opcode = "G02"
     end

     mill.plung(pBeg_z)     
     print opcode, " X", sprintf("%8.4f", cp.x), " Y",sprintf("%8.4f", cp.y) , " Z", sprintf("%8.4f", pEnd_z), " R",sprintf("%8.4f", pRadius) ,  " F",  sprintf("4.1f",pSpeed), "\n"
    @pcy = pyi
    @pcx = pxi
   end #meth



###############
# produces an simple arc by degree 
# did not use G02 and G03 because I 
# didn't want to have to figure out 
# clockwise verus counter clockwise
#
# TODO:  Make the G02 and G03 
#   changes to save code emission.
#
# # # # # # # # # # # # # # # # # # # 
def arc_radius(mill, pCent_x, pCent_y, pRadius, pBeg_deg, pEnd_deg, pBeg_z, pEnd_z, pAccuracy=0.05)
# # # # # # # # # # # # # # # # # # # 
 
 degree_inc = degrees_for_distance(pRadius, pAccuracy) #keep 
    # our degree calc so we get about 0.005 inch
    #  movement per degree which will keep the ragged
    #  edges off of our larger circles.
    
  #print "(arc_radius  pCent_x=", pCent_x, " pCent_y=", pCent_y, " pRadius=", pRadius,  " pBeg_deg=", pBeg_deg, " pEnd_deg=", pEnd_deg,  " pBeg_z=", pBeg_z,  "pEnd_z=", pEnd_z,  "degree_inc = ", degree_inc, ")\n"
  if (pBeg_deg > pEnd_deg)
    pEnd_deg = pBeg_deg
  end
  
  if (pBeg_z > 0)
    pBeg_z = 0 - pBeg_z
  end
  
  if (pEnd_z > 0)
    pEnd_z = 0 - pEnd_z
  end
  
  
 
  curr_depth = pBeg_z
  cnt = 0
  while true  
    curr_degree = pBeg_deg
    curr_depth -= mill.cut_depth_inc
    if (curr_depth < pEnd_z)
      curr_depth = pEnd_z
    end
    
    while (true)
      cnt += 1
      if  (curr_degree > pEnd_deg)
        curr_degree = pEnd_deg
      end
          
      cp = calc_point_from_angle(
                    pcx=pCent_x,
                    pcy=pCent_y, 
                    angle=curr_degree, 
                    length=pRadius)
      if (cnt == 1)
        mill.move(cp.x, cp.y)
         # move before first plung
         # to position prior to the first 
         # cut.
      end
      mill.plung(curr_depth)              
      mill.move(cp.x, cp.y)

      if (curr_degree == pEnd_deg)
        break
      else
        curr_degree += degree_inc
      end
    end # for degrees
    if (curr_depth == pEnd_z)
      break
    end
  end # while depth
end #method

      
   
   

   # Trace a curve around a defined circle from
   # a starting ppoint to a ending ppoint sloping
   # from a beginning to a ending Z ppoint. 
   # Originally
   # written to support milling the sloped area
   # of a fan blade.  Supports the concept of 
   # a curve which has a changing Z and 
   # changing pRadius as it goes.
   # The skip under pDepth and skip over pDepth
   # are an optimization to allow broader use.
   # because in many circumstances it is easier
   # to desribe a complete arc but since we have
   # to work down in layers all or part of the
   # curve can be skipped if it is above a 
   # or below the currently defined work plane. 
   # since head movment can be slow it is easier
   # to remove the movement here than it is to 
   # remove it latter.  Care must be used to ensure
   # not short circuiting a desired move.  In general
   # this would be used in conjunction with a arch that
   # is tracing back and forth to work down through
   # a material.
   # TODO:  A  Modify this to use G02, G03
   #  to minimize produced code volume.
   #   #   #   #   #   #   #   #   #
   def changing_radius_curve(mill, pcx, pcy, pBeg_radius, pBeg_angle,  pBeg_z,  pEnd_radius, pEnd_angle, pEnd_z,  pDegrees_per_step=nil, pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=true)
   #   #   #   #   #   #   #   #   #
   
         #print "(changing radius curve pcx=", pcx,  " pcy=", pcy, ")\n"  
        
         if (pDegrees_per_step == nil)
           pDegrees_per_step = degrees_for_distance(pEnd_radius, 0.01)  # This will give us smoother curves even when using larger circles.
         end
         #print "(pEnd_radius=", pEnd_radius, ")\n"
         #print "(pDegrees_per_step=", pDegrees_per_step, ")\n"
         
         total_step_count = 0
         
         pDepth_delta = pEnd_z - pBeg_z
         pRadius_delta = pEnd_radius - pBeg_radius
         degree_delta = pEnd_angle - pBeg_angle
         #print "(pBeg_angle=",pBeg_angle, ")\n"
         #print "(pEnd_angle=",pEnd_angle, ")\n"
         #print "(degree_delta=", degree_delta, ")\n"
         no_steps  = (degree_delta / pDegrees_per_step.to_f).to_i.abs - 1
         
         
         #print "(pDegrees_per_step=", pDegrees_per_step, ")\n"
    
        
         if (degree_delta == 0)
           return 
         end
         
         if (no_steps == 0)
           # this would only happen when the 
           # span of degrees is smaller than
           # the pDegrees_per_step which almost
           # never happens.
           no_steps = 1
           pDegrees_per_steps = degree_delta           
         end
         
         pDegree_inc    = degree_delta / no_steps.to_f
            # This recalc of the degree incrment is a
            # a little subtle.  To use a simple step 
            # interpolation if we used the simple division
            # above our final movement could be off by 
            # a fraction of 1 step.  By using this approach
            # we recalcuate the pDegree_inc by the newly
            # cacluatled number of steps which gives 
            # us a number accurate to the limits of the 
            # floating ppoint resolution.
         pDepth_inc     = pDepth_delta / no_steps.to_f
         pRadius_inc    = pRadius_delta / no_steps.to_f
         curr_degree    = pBeg_angle
         curr_z         = pBeg_z
         curr_pRadius   = pBeg_radius
         
         #print "(changing pRadius curve no_steps=", no_steps, "pDepth_inc=", pDepth_inc, " pRadius_inc=", pRadius_inc, " pBeg_z=", pBeg_z,  " pEnd_z = ", pEnd_z, ")\n"
         
         pass_cnt = 0
         tSpeed = mill.speed
         pSpeed_decrement = 0
         curr_speed = tSpeed
         if (pEnd_z < pBeg_z) and (pAuto_speed_adjust == true)
           # mill is gpoing deeper on this
           # curve so slow it down to 1/2 pSpeed
           # by the time it gets to it's maximum 
           # pDepth
           pSpeed_decrement = ((tSpeed / 2.0) / no_steps)
         end 
         if (  pSpeed_decrement > 0)
           pSpeed_decrement = 0
         end
   
         retract_after = no_steps / 4.0      
         retract_cnt   = 0
         for curve_cnt in (0..no_steps)
            cp = calc_point_from_angle(
                  pcx, pcy, 
                  curr_degree, 
                  curr_pRadius)
            
            if (total_step_count == 0)  
              #mill.retract(pBeg_z + 0.05)               
              mill.move_fast(cp.x,cp.y)              
              mill.plung(curr_z)
            end
            
            if (pSkip_z_GT != nil) and (curr_z > pSkip_z_GT)
               
            elsif (pSkip_z_LT != nil) and (curr_z < pSkip_z_LT)
              
            else
              mill.move(cp.x, cp.y, curr_z)
            end
            total_step_count += 1
            curr_z       += pDepth_inc
            curr_pRadius += pRadius_inc
            curr_degree  += pDegree_inc
            curr_speed   -= pSpeed_decrement
            mill.set_speed(curr_speed)
            retract_cnt += 1
            #if (mill.bit_diam < 0.187) && (retract_cnt >= retract_after)
            #   mill.retract()
            #   retract_cnt = 0
            #end                  
         end #for
         mill.set_speed(tSpeed)           
       end # meth
                  
   

      


###############
# produces an arc that is shaped to 
# move from a starting degree and pRadius
# to a new degree and pRadius on the
# outside.   Normally used for spiral
# type activities.
# # # # # # # # # # # # # # # # # # # 
def arc_to_radius(pMill, pCent_x, pCent_y, pBeg_radius,pBeg_deg, pEnd_radius,  pEnd_deg,pBegZ, pEndZ)
# # # # # # # # # # # # # # # # # # # 
  # start as center and 
  mill = pMill
  
  if (pBegZ > 0)
    pBegZ = 0 - pBegZ
  end
  if (pEndZ > 0)
    pEndZ = 0 - pEndZ
  end

  tot_step_cnt = 0
  #print "(arc_to_radius pCent_x=", pCent_x,  " pCent_y=", pCent_y, "pBeg_radius", pBeg_radius, "  pBeg_deg=", pBeg_deg,  " pEnd_radius=", pEnd_radius, " pEnd_deg=", pEnd_deg,  ")\n"

  # TODO:  Calculate the distance traveled along the arc
  #  and use it to adjust the amount of depth that can be
  #  calculated.   
  
  # TODO:  Add a flag which is a face on versus a incremental side cut and when face on we need to either run slower or take a more shallow cut.
  curr_deg     = pBeg_deg
  radius_delta = pEnd_radius - pBeg_radius
  degree_delta = pEnd_deg - pBeg_deg
  radius_inc   = pMill.cut_inc
  def_deg_step = degrees_for_distance(pBeg_radius, 0.02)
  print "(def_deg_step = ", def_deg_step, ")\n"
    # this is the number of degrees in 0.01 inches
    # or 1/100 of an inch. 
  no_steps_deg  = degree_delta / def_deg_step # One degree 
  print "(degree_delta=", degree_delta, ")\n"
  print "(radius_delta=", radius_delta, ")\n"
  print "(radius_inc=", radius_inc, ")\n"
  no_steps   = (radius_delta / radius_inc)
  if (no_steps_deg > no_steps)
    no_steps = no_steps_deg  
       # use what ever number of steps is greater 
       # by degree change or radius change. 
  end  
  
  # if there are not enough calculated steps
  # then increase automatically to use a larger
  # number to get some reasonably small granulatiry
  # of move.
  if (no_steps < 1)
    no_steps = 5    
  elsif (no_steps < 10)
    no_steps *= 5
  end
  
  no_steps = no_steps.to_i
  no_steps_f = no_steps.to_f
  radius_inc = radius_delta. / no_steps_f.abs
  degree_inc = degree_delta / no_steps_f.abs 
  depth_inc = (pMill.cut_depth_inc * 0.7) / (no_steps_f.abs   * 2.0) # have of the cut depth one way and one half on the way back
  curr_depth = pBegZ  
  cnt = 0
  depth_end_flag = false
  
  while (depth_end_flag == false)   
    curr_deg = pBeg_deg    
    curr_radius = pBeg_radius       
     
    for step_cnt in (1..no_steps)    
         cp = calc_point_from_angle(
                    pcx=pCent_x,
                    pcy=pCent_y, 
                    angle=curr_deg, 
                    length=curr_radius)
                    
         if (tot_step_cnt == 0)
           pMill.retract(pBegZ + 0.1)
           pMill.move_fast(cp.x,cp.y)
           pMill.move_fast(cp.x,cp.y, pBegZ)
           pMill.move(cp.x,cp.y)
           pMill.plung(curr_depth)    
         end
                               
         pMill.move(cp.x, cp.y, curr_depth)
         tot_step_cnt += 1
         curr_radius += radius_inc
         curr_deg    += degree_inc  
         curr_depth -= depth_inc 
         if (curr_depth < pEndZ)
           curr_depth = pEndZ
         end    
    end  # for

    if curr_depth == pEndZ 
      depth_end_flag = true
    end
    
    
    # Arch back to start           
    for step_cnt in (1..no_steps)
        cp = calc_point_from_angle(
                    pcx=pCent_x,
                    pcy=pCent_y, 
                    angle=curr_deg, 
                    length=curr_radius)
         pMill.move(cp.x, cp.y, curr_depth)
         tot_step_cnt += 1
         curr_radius -= radius_inc
         curr_deg    -= degree_inc        
         curr_depth  -= depth_inc 
         if (curr_depth < pEndZ)
           curr_depth = pEndZ
         end                    
    end  # for
  end # while depth

  pMill.retract(pBegZ)
  return 1

end # meth



