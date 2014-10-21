require 'CNCMill'
require 'CNCBit'
require 'CNCMaterial'
require 'CNCShapeBase'
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.


#  Mills a rectangular goove with an 
#  outer perimiter specified by by,by,ex,ey
#  multiple passes will be tanken to force
#  the groove to be at least thickness width.
#  The width of the groove is milled inside 
#  the specified area.  and if thickness is
#  too large will end up with the effect of
#  milling a simple rectangle 
#  bx,by,ex,ey area automatically adjusted to
#  accomodate milling bit width and the resulting
#  box will fit inside this spec.
# - - - - - - - - - - - - - - - -   
def mill_rect_groove(mill,  bx, by, ex, ey, thickness, depth)
# - - - - - - - - - - - - - - - -
	mill.retract(0.02)
	if (thickness <= mill.bit_diam)
	  print "(mill_rec_groove defaulting to single rect because thickness is less than bit_diam)\n"
	  mill.mill_rect( bx, by, ex, ey, depth)
	else	
          aRect =  CNCShapeRect.new(mill, 0,0, 0, 0, 0)
	  print "(Groove Front edge min Y = ", by, ")\n"
	  aRect.reset(bx,by,ex,by + thickness, depth) 	
	  aRect.do_mill()
  	  mill.retract(0.02)
	  
	  
	  print "(Groove Left Edge - min x = ", bx, ")\n"
	  aRect =  aRect.reset(bx,by, bx + thickness, ey, depth)
	  aRect.do_mill()
	  mill.retract(0.02)

	  print "(Groove Back edge - max y = ", ey, ")\n"
	  aRect.reset(bx,ey - thickness,ex, ey, depth)
	  aRect.do_mill()
  	  mill.retract(0.02)
	  
	  
	  print "(Groove right edge max X = ", ex, ")\n"
	  aRect.reset(ex - thickness, by, ex, ey, depth)
	  aRect.do_mill()
  	  mill.retract(0.02)
	end 
end  
  
  

    
    # mill a rectangular outline 
    # in layers by spiral down step by step.
    # if adjust_type = outside then the coordinates
    # will be adjusted to the inside box is equal 
    # to exact measurements by adding bit_radius to
    # each coordinate.  If = "in"  then adjusted by 
    # subracting bit_radius from coordinates
    # if "none" or nil then no adjustment done.
    # if round corner radius is set then the corners
    # will be rounded by this amount.
    # it works down to depth by addign 1/4 cut increment
    # to each leg of the rectangle thereby avoiding the
    # need for a plung.
    #
    # TODO: Implement the corner rounding logic
    #     A Subtract the radius from eachh corner
    #     point.   EG:  If cutting to 1" then
    #     we stop the line at  1 - (0.25 / 2.0)
    #     Calculate a point which is inside
    #     the box by the amount of the radius
    #     to cut.  on a 1,1 corner this would
    #     be  0.875, 0.875 and then use that 
    #     at the center point for the circle
    #     and draw an arch around that point.  
    #     the angles on the arch would be 
    #     adjusted for each corner.
    
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
    def mill_layered_rectangle_outline(mill, bx,by,bz,ex,ey,ez, round_corner_radius=0.25, adjust_type="out")
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
      if (by > ey)
        ty = by
        by = ey
        ey = ty
      end
      if (bx > ex)
        tx = bx
        bx = ex
        ex = tx
      end
      
      if adjust_type == "out"
       bx = bx - mill.bit_radius
       by = by - mill.bit_radius
       ex = ex + mill.bit_radius
       ey = ey + mill.bit_radius
      elsif adjust_type == "in"
       bx += mill.bit_radius
       by += mill.bit_radius
       ex -= mill.bit_radius
       ey -= mill.bit_radius
      end
      if (bz > 0)
        bz = 0 - bz
      end
      
      if (ez > 0)
        ez = 0 - ez
      end
      
      qcdi = mill.cut_depth_inc.abs / 4.0
      curr_depth = bz
      mill.move_fast(bx,by,bz)
      last_pass = false
      while (true)
       
        if (curr_depth <= ez)
          curr_depth = ez  
          last_pass = true
          qcdi = 0
        end
        if (curr_depth - (qcdi * 4.0)) < ez
          # adjust our increment to end on exactly
          # at depth.
          qcdi = (curr_depth - ez).abs * 0.25
        end
        
        
        mill.move(bx,by,curr_depth)
        mill.move(ex,by,curr_depth - qcdi * 1)
        mill.move(ex,ey,curr_depth - qcdi * 2)
        mill.move(bx,ey,curr_depth - qcdi * 3)
        mill.move(bx,by,curr_depth - qcdi * 4)
        
        curr_depth -= mill.cut_depth_inc 
        
        if last_pass == true
          break
        end
      
      end # while
    
    end #meth


# Creat a bevel on the on the X Axis that is the slope is present
# on the y axis.       If the bev_width is negative the slop is towards
# the lower X and if the bevel width is postive it is towards the 
# positve Y
def bevel_on_x(mill, bx,by,ex, bev_top, bev_bot, bev_width)
   print "(bevel on bx=", bx, " by=", by, " ex=", ex, " bev_top=", bev_top, " bev_bot=", bev_bot, " bev_width=", bev_width, ")\n"
   curr_x = bx
   last_x = bx
   ey = by + bev_width
   mill.move(bx,by,bev_top)
   while (curr_x <= ex)
      mill.move(curr_x, by, bev_top)
      mill.move(curr_x, ey, bev_bot)
      mill.move(last_x, ey, bev_bot)      
      if (curr_x == ex) 
         break
     end
      last_x = curr_x
      curr_x  = curr_x + mill.cut_inc * 0.7
      if (curr_x > ex)
	      curr_x = ex
      end
      mill.move(curr_x, by, bev_top)
   end # while	
end #meth


def bevel_on_y(mill, bx,by,ey, bev_top, bev_bot, bev_width)
   print "(bevel on y=", bx, " by=", by, " ey=", ey, " bev_top=", bev_top, " bev_bot=", bev_bot, " bev_width=", bev_width, ")\n"
   curr_y = by
   last_y = by
   ex = bx + bev_width
   mill.move(bx,by,bev_top)
   while (curr_y <= ey)
      mill.move(bx, curr_y, bev_top)
      mill.move(ex, curr_y,  bev_bot)
      mill.move(ex, last_y,  bev_bot)      
      if (curr_y == ey) 
         break
     end
      last_y = curr_y
      curr_y  = curr_y + mill.cut_inc * 0.7
      if (curr_y > ey)
	      curr_y = ey
      end
      mill.move(bx, curr_y, bev_top)
   end # while	
end #meth








  # *****************************************
  class CNCShapeRect 
  # *****************************************
    include  CNCShapeBase
    extend  CNCShapeBase

     # initialize a rectrangle for milling
     # requires a center point, width
     # and length.
     # - - - - - - - - - - - - - - - -   
     def initialize(mill,  x=0, y=0, width=0.5, len=0.5, depth=-0.5)
     # - - - - - - - - - - - - - - - -
         base_init(mill,x,y,mill.cz,depth)
         #print "rect initialize after base_init depth=", @depth, "\n"
         len = len.abs
         width = width.abs
         @len     = len
         @width = width
         @lx       = x
         @ly       = y
         @mx     = x + width
         @my     = y + len
         @include_finish_cut = true
	 @save_speed = mill.speed
         self
       end  # init 


      # Force the square to be centered over
      # the X,Y coordinate rather than using
      # X,Y as first corner.
      # - - - - - - - - - - - - - - - -     
      def centered(scx=@x,scy=@y,width=@width,length=@len, depth=@depth)
      # - - - - - - - - - - - - - - - -  
        #print "(centered scx=", scx, " scy=", scy, " width=", width, " length = ", length,  " depth= ", depth, ")\n"
        @width = width.abs
        @len     = length.abs
        @depth =depth
        wr = width / 2
        lr  = length / 2
        @lx       = scx - wr  
        @ly       = scy - lr
        @mx     = scx + wr
        @my     = scy + lr
	@save_speed = mill.speed
        self
      end #meth

      # Force the square to be centered over
      # the X,Y coordinate rather than using
      # X,Y as first corner.
      # - - - - - - - - - - - - - - - -     
      def reset (lx,  ly,  mx,  my,  depth=@depth)
      # - - - - - - - - - - - - - - - -     
        if (lx > mx)
          tx = lx
          lx  = mx
          mx = tx
        end #if

        if (ly > my)
          ty = ly
          ly  = my
          my = ty
        end

        @width = mx - lx
        @len    =  my - ly
        @depth =depth
        @lx   = lx
        @ly   = ly
        @mx = mx 
        @my = my 
        self
      end #meth

     #- - - - - - - - - - - - - - - - - - 
     def include_finish_cut
     #- - - - - - - - - - - - - - - - - -
        @include_finish_cut = true
     end # meth

     #- - - - - - - - - - - - - - - - - - 
     def skip_finish_cut
     #- - - - - - - - - - - - - - - - - -
        @include_finish_cut = false
     end # meth


     # Perform the actual milling to based on current parameters
     #- - - - - - - - - - - - - - - - - -
      def do_mill
     #- - - - - - - - - - - - - - - - - -
      @save_speed = mill.speed
       mill_cavity(@lx,@ly,@mx,@my, @depth)
       self
      end #meth


     # - - - - - - - - - - - - - - - -     
     def mill_cavity(lx,ly, mx, my, depth)
     # - - - - - - - - - - - - - - - -     
       print " (mill cavity @depth=", @depth, " lx=", lx, " ly=", ly, " mx=", mx, " my=",my, " depth=", depth,  ")\n"
     @save_speed = mill.speed
     # swap the X values to make mx the high one
      if (lx > mx)
        print "(mill_cavity swap lx,mx)\n"
        tx = mx
        mx = lx
        lx = tx
      end #if
       
     # swap Y values to make my the high one
      if (ly > my)
        print "(mill_cavity swap ly,my)\n"
        ty = my
        my = ly
        ly = ty
      end #if

      # Adjust the interior Cavity
      # to allow for the size of the
      # bit or the milled cavity would 
      # be too large   
      lx += bit_radius
      ly += bit_radius
      my -= bit_radius
      mx -= bit_radius  
      #print "(after adjust for bit radius  lx=",lx, " ly=",ly, " mx=",mx, " my=", my, " bit_radius=", bit_radius, ")", "\n"


      # if the bit is not already over the cavity to be
      # milled then we have to retract it before moving
      # to that location
      if ((@mill.cx < lx) or (@mill.cx > mx) or (@mill.cy < ly) or (@mill.cy > my)) 
        print "(mill rect auto rectract)\n"
        @mill.retract()
        @mill.move_fast(lx,ly)        
      end #if

       if depth.abs <= mill.cut_depth_inc        
         mill_cavity_s(lx,ly,mx,my,depth)
         return
      else
        dd = beg_depth
        while true
          dd -= mill.cut_depth_inc
          if (dd < depth)
            dd = depth
          end     
          mill_cavity_s(lx,ly,mx,my,dd)
          if (dd == depth)
            break
          end #if
        end #while
      end #else      
    end #meth


    # - - - - - - - - - - - - - - - -     
    def mill_cavity_s(lx,ly, mx, my, dd2)
    # - - - - - - - - - - - - - - - -     
      #print "(mill rect cavity lx=",lx, " ly=",ly, " mx=",mx, " my=", my,  " depth=", dd2, ")", "\n"
      @save_speed = mill.speed 
      tSpeed = mill.speed
       
      lcx = lx
      lcy = ly
    
      # start at inside and mill
      # towards the outside
      dx = (mx - lx).abs
      dy = (my - ly).abs
      mid_x = lx + (dx / 2)
      mid_y = ly + (dy / 2)
      no_pass_x = ((dx / cut_inc) / 2)
      no_pass_y = ((dy / cut_inc) / 2)
      #print "(cut_increment_rough=", cut_increment_rough, ")\n"
      # if we have a long narrow cut we want to emphasize
      # cutting along the long axis to save time.
      if dy > dx
        # difference in Y is greater than difference in X so 
        # emphasize cutting on Y first.
        percent_dif = dx / dy
        begylen = dy - (no_pass_x  * cut_inc)
        if (begylen < bit_diam)
          begylen = bit_diam
        end
        begxlen = bit_radius
        no_pass = no_pass_x
        #print "(mill_rect emphasize Y begylen=", begylen, "  begxlen=", begxlen, ")\n"
        #print "( dx=", dx, "  dy=", dy,  " mid_x=", mid_x,  " mid_y=", mid_y, ")\n"
      else
        # emphasize cutting on the X axis first
        percent_dif = dy / dx
        begxlen = dx - (no_pass_y * cut_inc)
        if (begxlen < bit_diam)
          begxlen = bit_diam
        end
        begylen = bit_radius
        no_pass = no_pass_y
        #print "(mill_rect emphasize X  begxlen=", begxlen, " begylen=", begylen, ")\n"
        #print "( dx=", dx, "  dy=", dy,  " mid_x=", mid_x,  " mid_y=", mid_y, ")\n"
      end #i

      
      #print "(begxlen = ", begxlen, "  begylen=", begylen,  " mid_x=", mid_x, "  mid_y =", mid_y, "  no_pass=", no_pass, ")\n"


      # Based on the chosen favorable cut axis 
      # calcualte the initial length of each X,Y
      clx   = mid_x -  (begxlen / 2)
      cly   = mid_y - (begylen / 2)
      cmx = mid_x + (begxlen / 2)
      cmy = mid_y  + (begylen / 2)

      if (clx < lx)
        clx = lx
      end
      if (cly < ly)
         cly = ly
      end
      if (cmx > mx)
        cmx = mx
      end
      if (cmy > my)
        cmy = my
      end


      #print "(L217:  clx=", clx, "  cly=",  cly,  " cmx=", cmx, "  cmy=", cmy, ")\n"
 
 

      if ((mx - cmx) < cut_inc && ((my - cmy) < cut_inc))  || (@include_finish_cut == false)
        #set_speed_rough
        curr_cut_inc  = cut_inc        
      else
        #set_speed_finish
        curr_cut_inc  = cut_inc
       
      end

      pass_cnt = 0
   
      while true
        #print " (L228  clx=", clx, "  cly=",  cly,  " cmx=", cmx, "  cmy=", cmy, ")\n"
        
        pass_cnt += 1
        if (pass_cnt <= 1)
          mill.set_speed(tSpeed/4.0)
        else
          mill.set_speed(tSpeed)
        end
        
        @mill.move(clx,cly)
        if (pass_cnt == 1)
          @mill.plung(dd2) 
        end
        @mill.move(clx,cmy)	
        @mill.move(cmx,cmy)
	mill.set_speed(tSpeed)
        @mill.move(cmx,cly)
        @mill.move(clx,cly)

        if (cmx == mx) && (cmy == my)
          #print "(exactly matched requeseted raidius so done)\n"
          break  # finished the loop
        end  #if 

        if (((cmx + curr_cut_inc) > mx) || ((cmy + curr_cut_inc) > my)) &&  (@include_finish_cut == true)
          #print "(L240 starting finish cut)"
          #set_speed_finish
          curr_cut_inc = cut_inc
        end

        clx -= curr_cut_inc
        cly -= curr_cut_inc
        cmx += curr_cut_inc
        cmy += curr_cut_inc

        if (cmx > mx)
          #print "(exceed mx ", mx, " so set back)\n"
          cmx = mx
        end

        if (clx < lx)
          #print "(exceed lx=", lx, " clx=", clx, ")\n"
          clx = lx
        end

        if (cmy > my)
          #print "(exceed my", my, " so set back)\n"
          cmy = my
        end
       
       
       if (cly < ly)
          #print "(exceed ly=", ly, "  cly=", cly, ")\n"
          cly  =  ly
       end
      end #while
      #@mill.move(lx,ly) # setup for next pass
      #set_speed_rough
      mill.set_speed(tSpeed)
    end #meth       
  end # class

  
  
  