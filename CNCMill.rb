# cncMill.rb
#
# #  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.


require 'CNCBit'
require 'CNCMaterial'
require 'CNCGeometry'
require 'CNCExtent'
require 'CNCMachine'
require 'CNCJob'


# Class to be filled in for the mill which
# gives us a conversion of  F# type speeeds
# of Feet Per Minute.  This is needed To
# map our calculations for optimal speeds
# to an approapriate feed rate.
#

###################################
class CNCFeedSpeeds
###################################
 


end #class


# *****************************************
class CNCMill 
# *****************************************
   attr_accessor :curve_granularity
   
   # - - - - - - - - - - - - - - - -   
   def initialize(config_file_name=nil, material_file_name=nil, machine_file_name=nil, job_file_name=nil)
   # - - - - - - - - - - - - - - - -
     @cz          = 0.0
     @cx          = 0.0
     @cy          = 0.0
     @current_bit    = CNCBit.new(self)
     @mill_depth  = -0.05
     @retract_depth = 0.1
     @no_move_count = 0
     @curve_granularity = 0.006
        # This is the linear distance along
        # a curve to use as the degree increment
        # when we are inerpolating Set to a higher
        # number for smaller GCODE but shapes where
        # the curves are not as smooth and a smaller
        # number for when curves need to be very smooth.
        
     
     
     if (material_file_name == nil)
       @material = CNCMaterial.new(self)
     else
       @material = CNCMaterial.new(self, material_file_name)
     end
     
     
     if (machine_file_name == nil)
       @machine       = CNCMachine.new(self)
     else
       @machine       = CNCMachine.new(self, machine_file_name)
     end
     
     if (job_file_name == nil)
       @job = CNCJob.new(self)
     else
       @job = CNCJob.new(self, job_file_name)
     end
     
     @curr_speed = current_bit.get_fspeed()
    
     current_bit.recalc()
     
   end  # init 

   def material
     @material
   end #meth
   
   def job
     @job
   end
   
   def machine
      @machine
   end
   
   # - - - - - - - - - - - - - -
   def job_start
   # - - - - - - - - - - - - - -
     print "%\n"
   end 

   # - - - - - - - - - - - - - -
   def job_finish
   # - - - - - - - - - - - - - -
     print "%\n"
   end 

   ###########
   def pause(message=nil)
   ##########
     if (message == nil)
        message = "PAUSE"
     end #if
     print "\nM01 (", message, ")\n\n"
   end  #meth
   
   ###########
   def mount_bit(bit_num, message=nil)
   ##########
     if (message != nil)
        pause(message)
     end #if
     print "\nT", bit_num, " M06\n"
   end  #meth
   


   # - - - - - - - - - - - - - - - -   
   def move(xo,yo=@cy,zo=@cz,so=nil)
   # - - - - - - - - - - - - - - - -
     opcode = "G01 "  
     if (so == nil)
       so = self.speed()
     end
     
     speed_str =  sprintf(" F%4.1f", so)
          
     if (so == 34)
       opcode = "G00 "
       speed_str = ""
     end
     
     #print "(xo=", xo,")\n"     
     #print "( move xo=", xo, " yo=",yo,  " zo=", zo,  " so=", so, ")\n"
     if (xo ==@cx) && (yo == @cy) && (zo == @cz)
       #print "(move - already positioned)\n"
       @no_move_count += 1
     else
       if (xo > max_x)
         #print "(move x=", sprintf("%8.4f",xo), " GT max of ", @max_x, ")\n"
         xo = max_x
       elsif (xo < min_x)
         #print "(move x=", sprintf("%8.4f",xo), " LT min of ", @min_x, ")\n"
         xo = min_x
       end #if
       if (yo > max_y)
         #print "(move y=", sprintf("%8.4f",yo), " GT max of ", @max_y, ")\n"
         yo = max_y
       elsif (yo < min_y)
         #print "(move y=", sprintf("%8.4f",yo), " LT min of ", @min_y, ")\n"
         yo = min_y
       end #if
       if (zo > max_z)
         #print "(move z=", sprintf("%8.4f",zo), " GT max of ", @max_z, ")\n"
         zo = max_z
       elseif (zo < min_z)
         #print "(move x=", sprintf("%8.4f",zo), " LT min of ", @min_z, ")\n"
         zo = min_z
       end #if



       if ((xo != @cx) && (yo != @cy) && (zo != @cz))
         print opcode, " X", sprintf("%8.4f", xo), " Y", sprintf("%8.4f", yo)," Z", sprintf("%8.4f", zo), speed_str, "\n"
       elsif ((xo != @cx) && (yo != @cy))
         print opcode, " X", sprintf("%8.4f", xo), " Y",sprintf("%8.4f", yo),speed_str, "\n"
       elsif ((xo != @cx) && (zo != @cz))
         print opcode, " X", sprintf("%8.4f", xo), " Z",sprintf("%8.4f", zo),speed_str, "\n"
       elsif ((yo != @cy) && (zo != @cz))
         print opcode, " Y", sprintf("%8.4f", yo), " Z",sprintf("%8.4f", zo),speed_str, "\n"
       elsif (xo != @cx) 
         print opcode, " X",sprintf("%8.4f", xo),speed_str, "\n"
       elsif (yo != @cy) 
         print opcode, " Y",sprintf("%8.4f", yo),speed_str, "\n"
       elsif (zo != @cz) 
         print opcode, " Z",sprintf("%8.4f",zo),speed_str, "\n"
       else
         print opcode, " X", sprintf("%8.4f", xo), " Y",sprintf("%8.4f", yo)," Z",sprintf("%8.4f", zo),speed_str, "\n"
       end
         
       @cx = xo
       @cy = yo
       @cz = zo
     end #if
   end #meth


   # - - - - - - - - - - - - - - - - - -
   def cz
   # - - - - - - - - - - - - - - - - - -  
     @cz
   end #meth

   # - - - - - - - - - - - - - - - - - -
   def cx
   # - - - - - - - - - - - - - - - - - -  
     @cx
   end #meth

   # - - - - - - - - - - - - - - - - - -
   def cy
   # - - - - - - - - - - - - - - - - - -  
     @cy
   end #meth

   # - - - - - - - - - - - - - - - -     
   def curr_bit
   # - - - - - - - - - - - - - - - -      
     return current_bit()
   end

 # - - - - - - - - - - - - - - - -     
   def curr_bit=(aBit)
   # - - - - - - - - - - - - - - - -           
     set_current_bit(aBit)
     self
   end


   # - - - - - - - - - - - - - - - -     
   def current_bit
   # - - - - - - - - - - - - - - - -      
     return @current_bit
   end

   
   # - - - - - - - - - - - - - - - -     
   def current_bit=(aBit)
   # - - - - - - - - - - - - - - - -      
     set_current_bit(aBit)
     self
   end

   # - - - - - - - - - - - - - - - -     
   def set_current_bit(aBit)
   # - - - - - - - - - - - - - - - -      
     @current_bit = aBit
     self
   end
   
   # - - - - - - - - - - - - - - - -
   def bit_radius
   # - - - - - - - - - - - - - - - -
     curr_bit.radius
   end #meth

   # - - - - - - - - - - - - - - - -
   def bit_diam
   # - - - - - - - - - - - - - - - -
     curr_bit.diam
    end #meth

  # - - - - - - - - - - - - - - - -
  def flute_len
  # - - - - - - - - - - - - - - - -  
     curr_bit.flute_len
  end #meth

  # - - - - - - - - - - - - - - - -
  def cut_increment
  # - - - - - - - - - - - - - - - -
    # TODO: Modify this so that it gets
    #   the cut increment based on current
    #   speed setting finish or rough
    #   and material selected.  The cutting
    #   bit should calculate this by using
    #   the material that it can obtain
    #   from the mill.
    return curr_bit.cut_inc
   end #meth

 # - - - - - - - - - - - - - - - -
  def set_cut_increment_rough
  # - - - - - - - - - - - - - - - -
    curr_bit.set_cut_increment_rough
   end #meth
   
   # - - - - - - - - - - - - - - - -
   def set_cut_increment_finish
   # - - - - - - - - - - - - - - - -  
     curr_bit.set_cut_increment_finish
   end #meth 

  # - - - - - - - - - - - - - - - -
  def cut_inc=(aNum)
  # - - - - - - - - - - - - - - - -
    curr_bit.cut_inc = aNum
  end
  
  # - - - - - - - - - - - - - - - -
  def cut_inc
  # - - - - - - - - - - - - - - - -
    curr_bit.cut_inc
   end #meth
   
  # - - - - - - - - - - - - - - - -
  def set_cut_inc(aNum)
  # - - - - - - - - - - - - - - - -
    curr_bit.cut_inc = aNum
  end
  
      

   # Returns the current cutting 
   # depth increment.  This is based
   # on the current material, type 
   # of bit,  size of mill and 
   # whether finish cutting or rough
   # cutting.   The mill will make this
   # number have to make a number of
   # passes to make deeper cuts and the
   # total number is generally calculated
   # by dividing total depth of cut by
   # this number.   The method 
   # set_speed_finish will generally cause
   # this method to returrn a smaller number
   # than when set_speed_rough is used.
   # - - - - - - - - - - - - - - - -
   def cut_depth_inc_curr
   # - - - - - - - - - - - - - - - -  
     return curr_bit.cut_depth_inc
     # TODO: enhance this so that it
     #   is using bit and material
     #   knowledge to determine proper
     #   cut depth.
   end #meth 

   # - - - - - - - - - - - - - - - -
   def cut_depth_inc
   # - - - - - - - - - - - - - - - -  
     return curr_bit.cut_depth_inc
   end #meth 
   
   # - - - - - - - - - - - - - - - -  
   def set_cut_depth_inc(aNum)
   # - - - - - - - - - - - - - - - -  
     curr_bit.cut_depth_inc = aNum    
   end #meth 

   # - - - - - - - - - - - - - - - -  
   def cut_depth_inc=(aNum)
   # - - - - - - - - - - - - - - - -  
     set_cut_depth_inc(aNum)     
   end #meth 
      
   # - - - - - - - - - - - - - - - -
   def cut_depth_rough
   # - - - - - - - - - - - - - - - -  
     curr_bit.cut_depth_rough
   end #meth 

   # - - - - - - - - - - - - - - - -
   def cut_depth_finish
   # - - - - - - - - - - - - - - - -  
     curr_bit.cut_depth_finish
   end #meth 


   # - - - - - - - - - - - - - - - -     
   def move_y(yo, zo=@cz, so=nil)
   # - - - - - - - - - - - - - - - -     
     move(@cx,yo,zo,so)
   end #meth
     
     
   # - - - - - - - - - - - - - - - -     
   def move_z(zo, so=nil)
   # - - - - - - - - - - - - - - - -     
     move(@cx,@cy,zo,so)
   end #meth
     
     
   # - - - - - - - - - - - - - - - -     
   def retract(depth = @retract_depth)
   # - - - - - - - - - - - - - - - -     
     if (depth == nil)
       depth = @retract_depth
     end #if
     if (@cz == depth)
       @no_move_count += 1
     else
       if (depth > max_z)
         depth = max_z
       elsif (depth < min_z)
         depth = min_z
       end #else
      
       print "G00 Z",sprintf("%8.4f", depth) , " (retract) \n"
       @cz = depth
     end #else
   end #meth

   def plung_speed
      curr_bit.plung_speed
   end
   
   def plung_speed=(aSpeed)
      curr_bit.set_plung_speed(aSpeed)
   end
   
   def set_plung_speed(aSpeed)
      curr_bit.set_plung_speed(aSpeed)
   end
   
   # Move the bit down to a specified depth.
   # if this is going to result in a drilling
   # operation use the drill method instead
   # beg_depth is specified will be used to 
   # determine how far down the bit can move
   # fast before it is likely to hit hard 
   # material.
   # - - - - - - - - - - - - - - - -
   def plung(depth = nil, beg_depth=nil)
   # - - - - - - - - - - - - - - - -     
     if (depth == nil)
       depth = mill_depth
     end #if
     if (beg_depth == nil)
       beg_depth = @cz
     end
     
     if (depth == @cz)
        @no_move_count += 1
        return
     else
       second_move_needed = true
       if (depth > machine.max_z)
         depth = machine.max_z
       elsif (depth < machine.min_z)
         depth = machine.min_z
       end #if
       
       
       if (depth >= 0)
         # if depth is above zero then
         # moving in air so can go fast.
         #move_fast(@cx,@cy, depth) 
         print "G00 Z",sprintf("%8.4f",depth), " (plung above 0)\n"
         second_move_needed = false
       elsif (depth > @cz)
         # if beg_depth is higher than
         # current @cz then actually
         # a retract and can go fast.
         retract(depth)
         #print "G00 Z",sprintf("%8.4f",depth), " (plung above current is retract)\n"         
         # no use moving slow until we get to
         # an area where the bit may touch the
         # actual material
         second_move_needed = false
       elsif (@cz > beg_depth) 
         # if beg_depth is higher than
         # current @cz then actually
         # a retract and can go fast.         
         print "G00 Z",sprintf("%8.4f",beg_depth), " (plung fast to current plane)\n"         
         # no use moving slow until we get to
         # an area where the bit may touch the
         # actual material         
         second_move_needed = true
       elsif (@cz > 0.02) && (depth < 0)
         # if @cz is in the air and the 
         # destination for the bit
         # is below then we can at least
         # move fast to the surface of the
         # material.
         print "G00 Z0.02 (plung to zero fast)\n"         
       end
       
       if second_move_needed == true
         print "G01 Z", sprintf("%8.4f", depth), " F", sprintf("%8.4f", plung_speed()), " (plung)\n"
       end #if
       @cz = depth
     end #if
   end #meth


   # - - - - - - - - - - - - - - - -     
   def  mill_depth
   # - - - - - - - - - - - - - - - -     
     @mill_depth
   end #if

   # - - - - - - - - - - - - - - - -     
   def  mill_depth(depth)
   # - - - - - - - - - - - - - - - -     
        if (depth < machine.max_z)
           depth =   machine.max_z
        elsif (depth < machine.min_z)
           depth = machine.min_z
        end #if
        @mill_depth = depth
        return @mill_depth
   end #meth
    
   
   def retract_depth=(depth)
     @retract_depth = depth
   end #
   
   # - - - - - - - - - - - - - - - -    
   def speed
   # - - - - - - - - - - - - - - - -     
     return curr_bit.speed
   end # meth
    

   # - - - - - - - - - - - - - - - -    
   def set_speed(aSpeed)
   # - - - - - - - - - - - - - - - -     
     curr_bit.set_speed(aSpeed)
   end # meth


   # - - - - - - - - - - - - - - - -    
   def set_speed_rough
   # - - - - - - - - - - - - - - - -     
     curr_bit.set_speed_rough()
   end # meth

   # - - - - - - - - - - - - - - - -    
   def set_speed_finish
   # - - - - - - - - - - - - - - - -     
     curr_bit.set_speed_finish()
   end # meth



   # - - - - - - - - - - - - - - - -
   def home
   # - - - - - - - - - - - - - - - - 
     if (@cz == @retract_depth) && (@cy == 0) && (@cx == 0)
       @no_move_count += 1
     else
       retract
       print "G00 X0 Y0 (HOME) \n"
       @cx = 0
       @cy = 0
     end #if
   end #meth



   # - - - - - - - - - - - - - - - -
   def min_y=(aNum)
   # - - - - - - - - - - - - - - - - 
     machine.min_y  = aNum
   end #meth
   # - - - - - - - - - - - - - - - -
   def min_y
   # - - - - - - - - - - - - - - - - 
     return machine.min_y
   end # meth
   # - - - - - - - - - - - - - - - -
   def max_y=(aNum)
   # - - - - - - - - - - - - - - - - 
     #print "(CNCMill.max_y aNum=", aNum, ")\n"
     machine.max_y  = aNum
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_y
   # - - - - - - - - - - - - - - - - 
     return machine.max_y
   end # meth

   # - - - - - - - - - - - - - - - -
   def max_x_move=(aObj)
   # - - - - - - - - - - - - - - - - 
     machine.max_x_move = aObj
   end #meth


   # - - - - - - - - - - - - - - - -
   def min_x=(aObj)
   # - - - - - - - - - - - - - - - - 
     machine.min_x  = aObj
   end #meth

   # - - - - - - - - - - - - - - - -
   def min_x
   # - - - - - - - - - - - - - - - - 
     return machine.min_x
   end # meth

   # maximum allowed movement range
   # on the x axis.  This is a read
   # only variable because it is 
   # automatically calcualted by
   # adding @max_x_move + @min_x.
   # - - - - - - - - - - - - - - - -
   def max_x
   # - - - - - - - - - - - - - - - - 
     return machine.max_x
   end # meth

   # - - - - - - - - - - - - - - - -
   def max_x=(aObj)
   # - - - - - - - - - - - - - - - - 
     machine.max_x  = aObj
   end #meth


   # - - - - - - - - - - - - - - - -
   def min_a=(aObj)
   # - - - - - - - - - - - - - - - - 
     machine.min_a  = aObj
   end #meth
   
   # - - - - - - - - - - - - - - - -
   def max_a=(aObj)
   # - - - - - - - - - - - - - - - - 
     machine.max_a  = aObj
   end #meth
   
   # - - - - - - - - - - - - - - - -
   def min_z
   # - - - - - - - - - - - - - - - - 
     return machine.min_z
   end # meth
   
   # - - - - - - - - - - - - - - - -
   def min_z=(aObj)
   # - - - - - - - - - - - - - - - - 
     machine.min_z  = aObj
   end #meth

   # - - - - - - - - - - - - - - - -
   def max_z=(aObj)
   # - - - - - - - - - - - - - - - - 
     machine.max_z  = aObj
   end #meth
   # - - - - - - - - - - - - - - - -
   def max_z
   # - - - - - - - - - - - - - - - - 
     return machine.max_z
   end # meth





   # - - - - - - - - - - - - - - - -     
   def move_fast(xo,yo=@cy,zo=@cz)
   # - - - - - - - - - - - - - - - - 
     #print "move_fast xo=", xo, " yo=",yo,  " zo=", zo, ")\n"
     if (xo == @cx) && (yo == @cy)  && (zo == @cz)
       @no_move_count += 1
     else       
       move(xo,yo,zo,so=34)
       #print "      (move_fast)\n"
     end #if    
   end #meth



   # Mill a rectangle between the coordinates
   # specified.   The caller is responsible for either
   # pre-positioning the bit inside the rectangle
   # or retracting it prior to the call.   This method
   # does not supply any layer or flute length support
   # because it is normally called by higher level methods 
   # that do.    Used current speed which can be changed
   # by calling set_speed prior to calling this method
   # - - - - - - - - - - - - - - - -     
   def mill_rect_s(lx, ly, mx, my, depth, adjust_for_bit_radius=false)
   # - - - - - - - - - - - - - - - -
     # if needed swap lx and mx to ensure that
     # lx is the smaller number
      if (lx > mx)
        tt = lx
        llx = mx
        mx = tt
     end
      
     # if needed swap ly,my to make sure that
     # ly is the lower number.
     if (ly > my)
       tt = ly
       lly = my
       my = tt
     end


     if (adjust_for_bit_radius == true)
       lbr = bit_radius
       llx = lx + lbr
       lly = ly + lbr
       mx = mx - lbr
       my = my - lbr
     end

     # if our point is already inside the defined rectangle
     # then we assume it is safe to move without a retract
     if ((@cx < lx) || (@cx > mx) || (@cy < ly) || (@cy > my))
        retract()
     end

     # walk around the perimiter of the sqare
     move(lx,ly)
     plung(depth)  # if already at correct depth will
                         # just ignore
     move(lx,ly)
     move(lx,my)
     move(mx,my)
     move(mx,ly)
     move(lx,ly)

   end #meth

   
   # Mill a rectangle between the coordinates
   # specified.   The caller is responsible for either
   # pre-positioning the bit inside the rectangle
   # or retracting it prior to the call.   This method
   # does properly handel milling layers 
   # - - - - - - - - - - - - - - - -     
   def mill_rect(lx, ly, mx, my, depth, adjust_for_bit_radius=false)
   # - - - - - - - - - - - - - - - -
     if (cz <= 0)
       tBeg  = curr_depth = cz 
     else
       tBeg  = curr_depth = 0
     end
         
     check_move(lx,ly, tBeg, true)               
     while (curr_depth > depth)
       curr_depth -= cut_depth_inc
       if (curr_depth < depth)
         curr_depth = depth
       end
       print "(mill_rect lx=",lx," ly=", ly, " mx=",mx, " my=", my, " depth=", depth, " adjust_for_bit=", adjust_for_bit_radius, ")"

       mill_rect_s(lx,ly,mx,my,curr_depth, adjust_for_bit_radius)
     end
     retract(tBeg)
   end #meth

   
   
   # Mill a simple rectangle the diameter of the
   # the milling bit that follows the coordinates
   # speicified.   The caller is responsible to 
   # either pre-position the bit or retract the 
   # bit prior to calling.   This method
   # does not supply any layer or flute length support
   # because it is normally called by higher level methods 
   # that do.
   # - - - - - - - - - - - - - - - -     
   def mill_rect_centered(scx,scy,width,length, depth)
   # - - - - - - - - - - - - - - - -i
     lx = to_f(scx) - (width  / 2)  
     ly = to_f(scy) - (length / 2)
     mx = to_f(scx) + (width  / 2)
     my = to_f(scy) + (length / 2)
     mill_rect(lx,ly,mx,my, depth)
   end #meth

   # uses simple  trig function to calculate
   # distance between two points
   # - - - - - - - - - - - - - - - - - -
   def calc_distance(x1,y1,x2=@cx,y2=@cy)
   # - - - - - - - - - - - - - - - - - -
      #print "(calc_distance x1=", x1, " y1=", y1, " x2=", x2, " y2=", y2, ")\n"
      # TODO: Figure out how to call the cncGeometry version
      #   even though we have a name conflict.
      dx = (to_f(x1) - x2).abs
      dy = (to_f(y1) - y2).abs
      tdist =  Math.sqrt((dx*dx) + (dy*dy))
      return tdist
   end #meth

   

   # returns a point adjusted to 
   # fit the current max extents 
   # active for the mill. 
   # - - - - - - - - - - - - - - - - - -
   def apply_limits(xo, yo, zo=nil)
   # - - - - - - - - - - - - - - - - - -
     if (yo > max_y)
       yo = max_y
     end #if
     if (yo < min_y)
       yo = min_y
     end #if


     if (xo > max_x)
       xo = max_x
     end #if
     if (xo < min_x)
       xo = min_x
     end #if

     if (zo != nil)
       if (zo > max_z)
         zo = max_z
       end #if
       if (zo < min_z)
         zo = min_z
       end #if
     end #if


     np = CNCPoint.new(xo,yo,zo)
     return np
   end #meth

   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   def drill(cxi,cyi,beg_depth, end_depth) 
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
       # force depths to be negative
       # to allow passing either positive
       # or negative and still have work.              
       tSpeed = plung_speed()
       set_plung_speed(tSpeed * 0.8)
       if (beg_depth > 0)
         beg_depth = 0 - beg_depth
       end #if
       if (end_depth > 0)
         end_depth = 0 - end_depth
       end
       
       # swap beg and end if 
       # the end is less deep 
       # than beg.
       if (beg_depth < end_depth)
         tt = end_depth
         end_depth = beg_depth
         beg_depth = tt
       end
       
       # if not already over our drill 
       # point then  retract and move to
       # the drill point
       if (cxi != @cx) || (cyi != @cy)
         print "(Auto retract in drill )\n"
         if (@cz < beg_depth + 0.005)
           retract(beg_depth + 0.1)
         end
         move_fast(cxi,cyi)
       end 
       
       #move_fast(cxi,cyi, 0)
       move_fast(cxi,cyi, beg_depth)
       curr_depth = beg_depth
       
      
       # when drilling we push the bit in
       # a little and pull it out to clear
       # the chips and then do it over until
       # we hit our max depth             
       plung_cnt = 0
       last_full_retract_at = curr_depth
       plung_amount = cut_depth_inc / 4
       if (plung_amount > bit_diam / 15)
         plung_amount = bit_diam / 15
       end
       retract_amount = plung_amount * 3
       if (retract_amount < bit_diam / 4)
         retract_amount = bit_diam / 4
       end
       while(true)
         plung_cnt += 1        
         curr_depth -= plung_amount
         if (curr_depth < end_depth)
           break
         end
         plung(curr_depth)
                          
         # Back the bit out and place it again
         # between each plung to allow it to
         # clear.
         move_fast(cxi,cyi, 
             curr_depth + plung_amount * 3)
         move_fast(cxi,cyi, 
             curr_depth)
         
         # Retract the bit all the way out to current
         # plane every time we drill more than bit diamter.
         amount_since_last_full_retract = (curr_depth - last_full_retract_at).abs
         if (amount_since_last_full_retract > bit_radius)
           print "(Triggered full retract on drill at every bit_diam)\n"
           retract(beg_depth)
           move_fast(cxi,cyi, curr_depth)
           last_full_retract_at = curr_depth
         end
                                                 
       end #while 
       plung(end_depth)
       move_fast(cxi, cyi, beg_depth)
       set_plung_speed(tSpeed)
   end #method   

   
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   def cut_off(bx,by,bz,ex,ey,ez)
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
     flat_line(bx,by,bz,ex,ey,ez)
   end #meth   
   
   
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   def flat_line(bx,by,bz,ex,ey,ez)
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
     # cut off the by cutting back and forth on the
     # Y axis.
     #  Assume that we are cutting off the 0,0 end of 
     # the bar
     #  and that we had been milling on the part sticking out.
     tSpeed = speed()
     if (bz > 0)
       bz = 0 - bz
     end
   
     if (ez > 0)
       ez = 0 - ez
     end
   
     #print "(flat_line", bx, " by=", by, " bz=", bz, " ex=", ex, " ey=", ey,  " ez = ", ez, ")\n"
   
     move_fast(bx,by)
     move_fast(bx,by,bz)
     
     curr_depth = bz   
     move(bx,by)   
     plung(bz)
     
     while (ez <= curr_depth)
       curr_depth -= cut_depth_inc.abs
       if (curr_depth < ez)
         curr_depth = ez
       end
       #set_speed(tSpeed / 2)
       move(ex,ey, curr_depth)       
       #curr_depth -= cut_depth_inc.abs
       if (curr_depth < ez)
         curr_depth = ez
       end
       set_speed(tSpeed)
       move(bx, by, curr_depth)
       if (curr_depth == ez)
         break
       end
     end # while
     plung(ez)
     move(ex,ey)     
     move_fast(bx,by,bz)
     set_speed(tSpeed)

  end #meth  

   #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def restore_bit(aBit, material_type)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    set_current_bit(aBit)
    aBit.recalc()
    if (material_type != nil)
        aBit.adjust_speeds_by_material_type(material_type)
    end
    return aBit
  end # meth
 
 
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def load_bit(fiName, message, retract_amount, material_type=nil)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
      retract(retract_amount)      
      pause(message)
      bit2 = CNCBit.new(self, fiName)
      print "(bit2 diam=", bit2.diam, ")"
      set_current_bit(bit2)
      bit2.recalc()  
      print "(bit2 diam=", bit2.diam, ")"
      if (material_type != nil)
        bit2.adjust_speeds_by_material_type(material_type)
     end
      print "(bit loaded ", fiName, ")\n"
      print "(new diam = ", curr_bit.diam, " radius=", bit_radius, ")\n"
      return bit2
   end #meth
   
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def degrees_for_bit_diam(pRadius)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    return degrees_for_distance(pRadius, bit_diam)
  end
  
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def degrees_for_bit_radius(pRadius)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    return degrees_for_bit_diam(pRadius) / 2.0
  end
  
  
    #  #  #  #  #  #  #  #  #  #  #  #  #  #
  def degrees_for_cut_inc(pRadius)
  #  #  #  #  #  #  #  #  #  #  #  #  #  #
    return degrees_for_distance(pRadius, cut_inc)
  end
  
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   # determine if the head is already over a
   # specified location  and if it is not then
   # move it over that location.
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   def check_move(cxi,cyi,beg_depth=nil, full_retract=true) 
   #  #  #  #  #  #  #  #  #  #  #  #  #  #       
       # if not already over our drill 
       # point then  retract and move to
       # the drill point
       if (cxi != @cx) || (cyi != @cy)
         print "(Auto retract in drill )\n"                 
         if (full_retract == true) || (beg_depth == nil)
           retract()
         else
           retract(beg_depth + 0.1)
         end
         move_fast(cxi,cyi)
         if (beg_depth != nil)
           move_fast(cxi,cyi,beg_depth)
         end
       elsif (beg_depth != nil) && (beg_depth != @cz)
           plung(beg_depth)       
       end       
     end # meth

     
   
   # Simplified drill funtionality that 
   # does not attempt to be as smart as
   # the full drill funcitonality.  The 
   # assumption is that the mill bit is
   # the right size and does not require
   # any side milling functionality.  
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
   def drill_x(cxi,cyi, beg_depth, end_depth) 
   #  #  #  #  #  #  #  #  #  #  #  #  #  #
       # force depths to be negative
       # to allow passing either positive
       # or negative and still have work.              
       if (beg_depth > 0)
         beg_depth = 0 - beg_depth
       end #if
       if (end_depth > 0)
         end_depth = 0 - end_depth
       end
              
       # swap beg and end if 
       # the end is less deep 
       # than beg.
       if (beg_depth < end_depth)
         tt = end_depth
         end_depth = beg_depth
         beg_depth = tt
       end
                                   
       check_move(cxi,cyi,beg_depth=beg_depth, full_retract=false)
       curr_depth = beg_depth
       tSpeed = plung_speed()
       set_plung_speed(tSpeed * 2)
       plung_cnt = 0
       retract_cnt = 0
       while(true)
         plung_cnt += 1        
         retract_cnt += 1
         curr_depth -= cut_depth_inc * 2.5
         if (curr_depth < end_depth)
           curr_depth = end_depth
         end
         plung(curr_depth)                  
         if (retract_cnt > 5)
           retract()
           move_fast(cxi,cyi,beg_depth + 0.1)
           retract_cnt = 0
         else
           retract(beg_depth + 0.02)
           #retract(curr_depth + (cut_depth_inc.abs * 3))         
         end
         move_fast(cxi,cyi,curr_depth)                           
         if (curr_depth == end_depth)
           break
         end                                        
       end #while 
       plung(end_depth)
       retract()
       set_plung_speed(tSpeed)
       
   end #method   
  
  
end # class
