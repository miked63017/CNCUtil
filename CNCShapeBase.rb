# These methods are intended to 
# be included and extended in the
# CNC shape type objects
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

module CNCShapeBase

     # - - - - - - - - - - - - - - - -   
     def base_init(mill,x=0.0,y=0.0,z=nil, depth=0.2)
     # - - - - - - - - - - - - - - - -
         @mill                = mill
         @x                  = x
         @y                  = y
         if (depth == nil)
           depth = @mill.mill_depth
         end
         if (z == nil)
           @z = @mill.cz
         else
           @z                  = z
         end
         @depth           = depth
         
         @beg_depth        = 0.1;
	 @adjust_for_bit_diam = true
        # print "(CNCshape.Base.initialize mill=", mill, " depth=", @depth, ")\n"
       end  # init 

      # - - - - - - - - - - - - - - - -     
       def max(n1,n2,n3=nil,n4=nil,n5=nil,n6=nil)
      # - - - - - - - - - - - - - - - -     
         keep = n1
         if (n2 > keep)
           keep = n2
         end
         if n3 != nill && n3 > keep
           keep = n3
         end
         if n4 != nil && n4 > keep
           keep = n4
         end
         if n5 != nil && n5 > keep
           keep = n5
         end
         if n6 != nil && n6 > keep
           keep = n6
         end
        @keep
       end
       
      # - - - - - - - - - - - - - - - -     
       def min(n1,n2,n3=nil,n4=nil,n5=nil,n6=nil)
      # - - - - - - - - - - - - - - - -     
         keep = n1
         if (n2 < keep)
           keep = n2
         end
         if n3 != nill && n3 < keep
           keep = n3
         end
         if n4 != nil && n4 < keep
           keep = n4
         end
         if n5 != nil && n5 < keep
           keep = n5
         end
         if n6 != nil && n6 < keep
           keep = n6
         end
        @keep
       end

       # - - - - - - - - - - - - - - - -     
       def current_bit
       # - - - - - - - - - - - - - - - -      
         @mill.current_bit
       end

       # - - - - - - - - - - - - - - - -     
       def x(xi=nil)
       # - - - - - - - - - - - - - - - -     
          if (xi != nil)
            @x = xi
          end #if
          @x
       end  # meth

       # - - - - - - - - - - - - - - - -     
       def y(yi=nil)
       # - - - - - - - - - - - - - - - -     
          if (yi != nil)
            @y = yi
          end #if
          @y
       end  # meth

       # - - - - - - - - - - - - - - - -     
       def z(zi=nil)
       # - - - - - - - - - - - - - - - -     
          if (zi != nil)
            @z = zi
          end #if
          @z
       end  # meth
       

       
    # - - - - - - - - - - - - - - - -    
    def depth
    # - - - - - - - - - - - - - - - -      
      @depth
    end #meth

 # - - - - - - - - - - - - - - - -    
    def depth=(aDepth)
    # - - - - - - - - - - - - - - - -
        @depth = aDepth
    end #meth

    
    # - - - - - - - - - - - - - - - -    
    def beg_depth
    # - - - - - - - - - - - - - - - -
      @beg_depth
    end #meth

 # - - - - - - - - - - - - - - - -    
    def beg_depth=(aDepth)
    # - - - - - - - - - - - - - - - -
      @beg_depth = aDepth
    end #meth



       # - - - - - - - - - - - - - - - -     
       def retract(depth = nil)
       # - - - - - - - - - - - - - - - -      
         @mill.retract(depth)
         self
       end #meth

       # - - - - - - - - - - - - - - - -     
       def mill(aMill = nil)
       # - - - - - - - - - - - - - - - -      
          if (aMill != nil)
           @mill = aMill
          end #if
          @mill
       end

    # - - - - - - - - - - - - - - - - - -
    def bit_radius
    # - - - - - - - - - - - - - - - - - -
      @mill.current_bit.radius
    end #end if
    
    # - - - - - - - - - - - - - - - - - -
    def bit_diam
    # - - - - - - - - - - - - - - - - - -  
      @mill.current_bit.diam
    end #end if
    
    # - - - - - - - - - - - - - - - -     
    def flute_len
    # - - - - - - - - - - - - - - - -      
       @mill.flute_len
    end

    # - - - - - - - - - - - - - - - - - -
    def cut_increment_rough
    # - - - - - - - - - - - - - - - - - -  
      @mill.curr_bit.cut_increment_rough
    end #end if

    # - - - - - - - - - - - - - - - - - -
    def cut_increment_finish
    # - - - - - - - - - - - - - - - - - -  
      @mill.curr_bit.cut_increment_finish
    end #end if
    
    # - - - - - - - - - - - - - - - - - -
    def set_cut_increment_rough=(aDepth)
    # - - - - - - - - - - - - - - - - - -  
      @mill.curr_bit.set_cut_increment_rough =aDepth
    end #end if

    # - - - - - - - - - - - - - - - - - -
    def set_cut_increment_finish
    # - - - - - - - - - - - - - - - - - -  
      @mill.curr_bit.set_cut_increment_finish
    end #end if
    
    # - - - - - - - - - - - - - - - - - -
    def cut_inc
    # - - - - - - - - - - - - - - - - - -  
      @mill.cut_inc
    end #end if

          
    # - - - - - - - - - - - - - - - -
    def cut_set_depth_rough
    # - - - - - - - - - - - - - - - -  
      @mill.set_cut_depth_rough
    end #meth 

    # - - - - - - - - - - - - - - - -
    def set_cut_depth_finish
    # - - - - - - - - - - - - - - - -  
      @mill.set_cut_depth_finish
    end #meth 

	# - - - - - - - - - - - - - - - -
   def cut_depth_rough
   # - - - - - - - - - - - - - - - -  
      @mill.cut_depth_rough
   end #meth


	# - - - - - - - - - - - - - - - -
   def cut_depth_finish
   # - - - - - - - - - - - - - - - -  
      @mill.cut_depth_finish
   end #meth 
      
   
    # - - - - - - - - - - - - - - - -
    def cut_depth_inc
    # - - - - - - - - - - - - - - - -  
      @mill.cut_depth_inc
    end #meth 

   # - - - - - - - - - - - - - - - -    
   def set_speed(speed)
   # - - - - - - - - - - - - - - - -     
     @mill.set_speed(speed)
   end # meth

      
   # - - - - - - - - - - - - - - - -    
   def set_speed_rough
   # - - - - - - - - - - - - - - - -     
     @mill.set_speed_rough
   end # meth

   # - - - - - - - - - - - - - - - -    
   def set_speed_finish
   # - - - - - - - - - - - - - - - -     
     @mill.set_speed_finish
   end # meth

   # - - - - - - - - - - - - - - - -
   def home
   # - - - - - - - - - - - - - - - -     
     @mill.home
   end #meth

  # - - - - - - - - - - - - - - - - - -
  def cz
  # - - - - - - - - - - - - - - - - - -  
      @mill.cz
   end #meth
   
  # - - - - - - - - - - - - - - - - - -
   def cx
  # - - - - - - - - - - - - - - - - - -  
     @mill.cx
   end #meth

   # - - - - - - - - - - - - - - - - - -
   def cy
   # - - - - - - - - - - - - - - - - - -  
      @mill.cy
   end #meth

end # module


