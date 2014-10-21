# cncShapeCircle.rb
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

require 'CNCMill'
require 'CNCBit'
require 'CNCMaterial'
require 'CNCGeometry'
require 'CNCShapeBase'
require 'CNCShapeArc'

   #  PRIMITIVE: Caller is responsible to Adds
   #  Ability to detect need for multiple passes.
   #  and work down in layers.
   #  Does not handle multiple passes for depth.  If multiple passes m
   #  be needed then use the the CNCShapeCircle instead.
   # - - - - - - - - - - - - - - - - - -
   def mill_circle(mill, x,y, diam, beg_depth=@cz, depth=@cz, adjust_for_bit_radius=false, outside=false)
   # - - - - - - - - - - - - - - - - - -
     #print "mill circle x=", x, " y=", y, " diam=", diam, " depth=", depth, ")\n"
    if (diam < mill.bit_diam)
       print "(Warning mill circle diam is smaller than bit diam so drilling instead)\n"
       mill.drill(x,y,0,depth)
       return
    end #if
       
    if (depth > 0)
      depth = 0 - depth
    end
    if (beg_depth > 0)
      beg_depth = 0 - depth
    end
    
    
    # calculate if the current cx,cy coordinates are outside
    # the circle and if so perform an automatic retract
    tRad = mill.calc_distance(mill.cx, mill.cy, x,y)
    if (tRad > ((diam / 2) + 0.001))  
      mill.retract(beg_depth)
    end #if
     
     
    curr_depth =  beg_depth
    while (true)
       
        curr_depth -=  mill.cut_depth_inc
        
        if (curr_depth < depth)
          curr_depth = depth   
        end
         
        mill_circle_s(mill,x,y,diam, curr_depth,adjust_for_bit_radius, outside)
        
        if curr_depth == depth
          # last pass was for the finish
          # at exact depth desired
          break
        end
        
    end #while    
  
   end #meth
     
  

   #  PRIMITIVE: Caller is responsible to move the bit to a point inside
   #  the circle and to plung the bit the required depth
   #  prior to calling this function.   
   #
   #  Does not handle multiple passes for depth.  If multiple passes may
   #  be needed then use the the CNCShapeCircle instead.
   # - - - - - - - - - - - - - - - - - -
   def mill_circle_s(mill, x,y, diam, depth=@cz, adjust_for_bit_radius=false, outside=false)
   # - - - - - - - - - - - - - - - - - -
    #print "(mill circle_s x=", sprintf("%8.3f",x), " y=", sprintf("%8.3f",y), " diam=", sprintf("%8.3f",diam), " depth=", depth, ")\n"
     #print sprintf("(mill circle x=%8.3f y=%8.3f diam=%8.3f  depth=%8.3f)\n", x,y,diam,depth)
     
    cradius = diam / 2.0
    tspeed = mill.speed

    if (depth > 0)
      depth = 0 - depth
    end    
        
     # If we need to adjust for radius then we subtract our
     # bit radius from our circle diameter prior to milling the
     # arc segments.
     if (adjust_for_bit_radius == true)
       print "(mill circle adjust for radius is true)\n"
       cradius -= mill.bit_radius
     end #if


     # TODO:  It is supposed to be possible to mill the 
     #  complete circle with a single call but could not 
     #  make it work with EMC so needs further experiments
     # 
     # TODO: Double check this to for the mill climb direction
     # 

     ## Mill the 4 arc segments. 
     if (mill.cz > 0)
       mill.move_fast(x,y-cradius)
       mill.move_fast(x,y-cradius,0)
     end
     
     if outside == true
     
       mill.speed = tspeed / 2.0 # for starting point move slower
       mill.move(x,  y-cradius)  # This is our starting point
       mill.speed = tspeed
       mill.plung(depth)
   
       mill_arc(mill, x + cradius, y, cradius, mill.speed, "G02")
       mill_arc(mill, x, y + cradius, cradius, mill.speed, "G02")
       mill_arc(mill, x - cradius, y, cradius, mill.speed, "G02")
       mill_arc(mill, x, y - cradius, cradius, mill.speed, "G02")
     else # must be doing a pocket
   
       
        mill.move(x,  y-cradius)  # This is our starting point
       mill.plung(depth)
  
       mill_arc(mill, x + cradius, y, cradius, mill.speed, "G03")
       mill_arc(mill, x, y + cradius, cradius, mill.speed, "G03")
       mill_arc(mill, x - cradius, y, cradius, mill.speed, "G03")
       mill_arc(mill, x, y - cradius, cradius, mill.speed, "G03")
     end #if
   end #meth


   #  A circle utility that avoids the plung 
   #  at the beginning of every circle by spiraling down
   #  a cut incrment at a time.  This should be easier
   #  on the end mill than the circle then plung 
   #  and then next cirle
   #  be needed then use the the CNCShapeCircle instead.
   # Beg Z must be higher up or above the end Z because
   # the assumption is that we start at top on spiral donw.
   # - - - - - - - - - - - - - - - - - -
   def spiral_down_circle(mill, x,y, diam, beg_z=@cz, end_z=@cz, adjust_for_bit_radius=false, outside=false, auto_speed_adjust=false)
   # - - - - - - - - - - - - - - - - - -
    cradius = diam / 2.0
     # If we need to adjust for radius then we subtract our
     # bit radius from our circle diameter prior to milling the
     # arc segments.
     print "(spiral_down_circle x=", x, " y=", y, " diam=", diam, " beg_z", beg_z,  " end_z=", end_z, ")\n"
     
     aCircum = calc_circumference(cradius)
     total_step_count = 0
     if (beg_z > 0)
       beg_z = 0 - beg_z
     end
     if (end_z > 0)
       end_z = 0 - end_z
     end
     
     if (adjust_for_bit_radius == true)
       if outside == true
         cradius += mill.bit_radius
       else
         cradius -= mill.bit_radius
       end
     end #if
     curr_depth = beg_z    
     
     #print "(cradius = ", cradius, ")\n"
     
     tcut_depth_inc = mill.cut_depth_inc * 0.85
     if (aCircum < 2)
       tcut_depth_inc *= (aCircum * (2 / tcut_depth_inc))
         # reduce our cut depth increment to reflect
         # holes less than 1 inch in diam because
         # otherwise we would have too steep of a
         # cut on the smaller holes.
     end
     
     if (diam <= 0.250)
      tcut_depth_inc *= 0.8
     end
     
     #mill.plung(beg_z + 0.1)
     cp = calc_point_from_angle(
                  x, y, 
                  0, 
                  cradius)
     mill.move(cp.x,cp.y)
     
     
     while(true)
       
       if outside == true
         beg_deg = 360
         end_deg = 0
       else # must be doing a pocket
         beg_deg = 0
         end_deg = 360
       end      
             
       next_depth = curr_depth - tcut_depth_inc
       
       if ((next_depth - tcut_depth_inc) < end_z)
        deg_per_step = 0.5
       end
       
       if (next_depth < end_z)
         next_depth = end_z        
       else
         deg_per_step = 2
       end # if      
                   
         
       deg_per_step = degrees_for_distance(cradius, mill.curve_granularity)
       if (cradius < 0.5)
         deg_per_step = 0.5
       elsif (deg_per_step > 5)
         deg_per_step = 5
       end
       
       print "(deg_per_step=", deg_per_step, ")\n"
       print "(beg_deg=",  beg_deg, "  end_deg=", end_deg, ")\n"
       
      
     
       changing_radius_curve(mill, x, y, cradius, beg_deg,  curr_depth,  cradius, end_deg, next_depth,  pDegrees_per_step=deg_per_step, pSkip_z_LT=nil, pSkip_z_GT=nil,  pAuto_speed_adjust= auto_speed_adjust)
       
       if (mill.bit_diam < 0.187) 
          mill.retract()
       end
       
       if (curr_depth == end_z)
         break
       else
         curr_depth = next_depth
       end
       
     end # for
     
   end #meth
   

  # *****************************************
  class CNCShapeCircle 
  # *****************************************
    include  CNCShapeBase
    extend  CNCShapeBase

    # - - - - - - - - - - - - - - - - - - 
    def initialize(aMill,x=0.0,y=0.0,diam=0.25, depth=nil,island_diam=0.0)
    # - - - - - - - - - - - - - - - - - -
      if ((depth != nil) && (depth > 0))
        depth = 0 - depth
      end
      
      base_init(aMill, x,y,depth)
      @island_diam = island_diam
      @diam = diam
      return self
    end #meth


     # basically calls the mill operation for
     # using the interal values for this circle
     # object.
     # - - - - - - - - - - - - - - - -
     def do_mill
     # - - - - - - - - - - - - - - - - 
          return mill_pocket(
             @x, @y, 
             @diam, 
             @depth,
             @island_diam)
     end #if


     # Performs a basic millng operation
     # according to the specifications supplied.
     # This does not change the internal circle
     # object specifications.   This method will 
     # properly handle multiple passes required
     # to reach the requested depth.
     # - - - - - - - - - - - - - - - -     
     def mill_pocket(x,y,diam,
     depth=@mill.mill_depth,
     island_diam=0)
     # - - - - - - - - - - - - - - - -     
     
       print "(circle.mill_pocket  diam=", diam,  " depth=", depth,  " island_diam=", island_diam, " beg_depth=", beg_depth, " bit_diam=", @mill.bit_diam,  ")\n"
       
       if (depth > 0)
         depth = 0 - depth
       end
          
       if (diam <= @mill.bit_diam)
         print "(circle pocket diam is LE bit diam)\n"
         @mill.drill(x,y,beg_depth,depth)
         return
       end


       @mill.retract(beg_depth + 0.05)       
       @mill.move_fast(x,y)
      
       curr_depth = beg_depth
             
     # if (@adust_bit_diam == true)
      #  diam = diam - mill.bit_radius
      # print "(adjust diam for bit diam   bitradius=", mill.bit_radius,  "new_diam=", diam, ")"
     #end
	    
      while (true)
        # normally this will be a single pass
        # however for small holes we want to 
        # breadth first pass to allow better
        # cooling.
	    curr_depth = curr_depth - mill.cut_depth_inc
	
        if (curr_depth.abs > depth.abs)
          curr_depth = depth
        end
	    mill_pocket_s(x,y,diam,curr_depth,island_diam)
	  
        #if (mill.bit_diam < 0.125) 
        #   mill.retract(0.02)
        #end
	
        if (curr_depth == depth)
          # have ran a pass at the 
          # requested max depth
          break
	   end
      end # while depth
    end #meth


    #  mill a circle of a given diameter at 
    #  the specified x,y location to a specified depth
    #  leaving an island of the specified height in the
    #  center.     Adjust for radius is automatic
    #  substracted from cradius
    # - - - - - - - - - - - - - - - - - -
    def mill_pocket_s(x,y,diam,depth=@mill.mill_depth,island_diam=0, finish_last_pass=false)
    # - - - - - - - - - - - - - - - - - -
      print "(L445: Circle.mill_pocket_s x=",x, " y=",y, " diam=", diam, " depth=", depth, " island_diam=", island_diam,")\n"
      cradius = (diam / 2) - bit_radius     
      print "(cradius =", cradius, ")\n"
      trad = bit_radius/3
      rad_inc = @mill.cut_inc            
      tSpeed = mill.speed 
      if (trad > cradius)
	    print "(hole too small to allow normal movement)\n"
        trad = cradius
       end	
         
      if (island_diam != 0)
	    trad = (island_diam / 2) + bit_radius
	    if (trad > cradius)
	      print "(island to big for hole size - bit_diam)\n"
	      trad = cradius
        end # if
      end #if     
      
      
      cnt = 0
      while(true)
        cnt += 1      
        #print "(main loop circle pocket s)\n"
	    if (cnt < 2)
	      mill.set_speed(tSpeed / 1.8)
	      # on smaller circles the first plug it may be taking
	      # a larger cut swatch so give it a bit of extra time.	  
	      #print "(slow first loop ",  mill.speed, ")\n"
	    end #if
	
        if (trad > cradius)
          trad = cradius
        end #if
        
        tdiam = trad * 2
	    #print  "(trad=", trad, " tdiam=", tdiam, ")"
        mill_circle_s(mill,x,y,tdiam, depth)
        if (trad == cradius)
          break # have finished this process
        else #if         
          trad += rad_inc            
          if trad >= cradius
            trad = cradius            
            if (finish_last_pass == true)
              #  @mill.set_speed_finish()
            end
          end #if
        end #else
      mill.set_speed(tSpeed)
     end #while
     mill.set_speed(tSpeed)
   end #meth
 
  end #class


# lopsided circles are typically used to produce
# volutes for centrifuge and tesla style pumps.  
# # # # # # # # # # # # # # # # # # # # # # # # # #   
def mill_lopsided_circle(mill, cx, cy, beg_diam, end_diam, beg_degree, end_degree, beg_depth, end_depth)
# # # # # # # # # # # # # # # # # # # # # # # # # #    
   degree_inc   = 1.0
   deg_sweep    = end_degree - beg_degree
   no_deg_steps = deg_sweep / degree_inc
   beg_radius   = beg_diam / 2
   end_radius   = end_diam / 2
   beg_radius   -= mill.bit_radius
   end_radius   -= mill.bit_radius
   radius_dif   =  end_radius - beg_radius
   radius_inc   =  radius_dif / no_deg_steps
  
   if (beg_depth > 0)
     beg_depth = 0
   end 
   
   if (end_depth > 0)
     end_depth = 0 - end_depth
   end
  
   tSpeed = mill.speed
   curr_depth = beg_depth - mill.cut_depth_inc.abs 
   layer_cnt = 0
   mill.move_fast(cx,cy)
   while (true)
     # Start at center an mill out 
     # until we reach the maxium
     # radius
     layer_cnt += 1
     last_pass = false
     move_cnt = 0
     curr_deg = beg_degree
     pass_beg_radius = mill.bit_diam * 0.1
     mill.plung(curr_depth)
     pass_cnt = 0
     
     print "(Layer Cnt=", layer_cnt, ")\n"
     print "(Layer depth=", curr_depth, ")\n"
     while true
       pass_cnt += 1
       if (pass_cnt == 1)
         mill.set_speed(tSpeed/2.5)
       else
         mill.set_speed(tSpeed)
       end
              
       if (last_pass == true)
         break
       elsif (pass_beg_radius > beg_radius)
         pass_beg_radius = beg_radius
         last_pass = true
       end    
       curr_radius = pass_beg_radius
       curr_deg = beg_degree
       while(curr_deg <= end_degree)        
         cp = calc_point_from_angle(
                  cx,
                  cy, 
                  curr_deg, 
                  curr_radius)
         if (move_cnt == 0)
           mill.move_fast(cp.x, cp.y)
         else
           mill.move(cp.x, cp.y)
         end #if
         if (last_pass == false)
           curr_deg += (degree_inc*10)
           curr_radius += (radius_inc*10)
         else         
           curr_deg += degree_inc
           curr_radius += radius_inc
         end #if
         if (curr_radius > end_radius)
           curr_radius = end_radius
         end
         move_cnt += 1
       end #while
       one_third_x =(cp.x + cx + cx)/3
       one_third_y = (cp.y + cy+ cy)/3
       mill.move_fast(one_third_x,one_third_y)
       pass_beg_radius += mill.cut_inc
       #print "(new pass beg_radius=", pass_beg_radius, ")\n"
     end #while
   
     if (curr_depth == end_depth)
       break
     end #if
     curr_depth -= mill.cut_depth_inc.abs
     if (curr_depth < end_depth)
       curr_depth = end_depth
     end
   
   end #while
   mill.set_speed(tSpeed)

end #meth

