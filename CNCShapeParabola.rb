require 'CNCMill'
require 'CNCBit'
require 'CNCMaterial'
require 'CNCGeometry'
require 'CNCExtent'
require 'CNCMachine'
require 'CNCJob'
require 'CNCShapeBase'
require 'CNCShapeRect'
require 'CNCShapeCircle'
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.


 # - - - - - - - - - - - - - - - -    
 def calc_parab_y(x_in, fp_in)
 # - - - - - - - - - - - - - - - -
    lcy  = (x_in * x_in) / (fp_in * 4.0)
    lcy
 end #meth

# * * * * * * * * * * * * * 
class CNCShapeParabola
# * * * * * * * * * * * * * 
    include  CNCShapeBase
    extend  CNCShapeBase
    # - - - - - - - - - - - - - - - -      
    def initialize(mill, width, focus_y, depth,x_increment, focus_diam, cut_off_sides)
    # - - - - - - - - - - - - - - - -    
      base_init(mill)
	  three_eights = (3.0 / 8.0) * 0.95
	  one_quarter = 0.245
	  @width        = width
	  @reflector_radius = width / 2.0
	  print "(width input=", @width, ")\n"	  
	  @mill         = mill
	  @focus_y      = focus_y
	  @focus_y_bit_adj = focus_y + @mill.bit_radius
      @depth        = depth
      @y_off        = 0.0
	  @focus_diam   = focus_diam
	  @focus_radius = focus_diam / 2.0	  
	  @x_increment = x_increment	  
	  @align_hole_diam = one_quarter	  	        
      @min_x      = 0 - @reflector_radius
      @max_x      = @reflector_radius
      @min_y      = @y_off      
	  @y_at_radius  = calc_parab_y(@reflector_radius, focus_y) + @y_off
	  @max_y      = @y_at_radius
	  @focus_max_y  = focus_y + @focus_radius	  
	  @align_x_offset = 3.0
	  
	  if (@max_y > @mill.max_y)
	    print "(\n\n************************)\n"
	    print "(WARNING: Calculated Max Y is greater than Mill Capacity)\n"
		print "(calc max_y=", @max_y, " mill max_y=", @mill.max_y,  " focus point max y=", @focus_max_y, ")\n"
		print "(************************)\n\n"
	  else
	    print "(calc max_y=", @max_y, " mill max_y=", @mill.max_y,  " focus point max y=", @focus_max_y, ")\n"
	  end
	  
	  if (@max_x > @mill.max_x)
	    print "(\n\n************************)\n"
	    print "(WARNING: Calculated Max X is greater than Mill Capacity)\n"
		print "(calc max_x=", @max_x, " mill max_x=", @mill.max_x, ")\n"
		print "(************************)\n\n"
	  else
	    print "(calc max_x=", @max_x, " mill max_x=", @mill.max_x, ")\n"
	  end
	  
	  
	  
      @side_off   = 1.0      
	  #@align_y = calc_parab_y(@reflector_radius, focus_y) * 0.80	
	  @align_y = focus_y
	  
      @cut_off_sides = cut_off_sides	 
    end #meth
    
    
    # TODO: Walks a variable focus parabola point where at the inner 
    # area of the trough focuses lower than the outer so that
    # we spread our total focus point across a larger vertical
    # area.  This drecreases the focus sensitiviity for aiming
    # by allowing the focus point to shift slightly based on aiming
    # without having to to worry about having the light move off
    # primary focus point  One variable that is important is to 
    # keep the focus pont a bit higher to allow the light to 
    # enter at an angle under the horizontal air insulator. 
    # For a 12" wide trough the optimal focus point seems to be
    # 5 inches which will provide a 1.3" rise on the Y axis.
    # For a 24" trough the optimal focus point seems to be 6 inches which will 
    # provide a 6" rise.  So start at a 5 inch focus point and work up to a 6"
    # over time. 
    def produce_variable_focus_parabola(mill, width, inner_focus, outer_focus, x_inc = 0.01)
    
    
    end
    
    
    # - - - - - - - - - - - - - - - -    
    def max_x
    # - - - - - - - - - - - - - - - -
       @max_x
    end #meth

    # - - - - - - - - - - - - - - - -    
    def min_x
    # - - - - - - - - - - - - - - - -
       @min_x
    end #meth

    # - - - - - - - - - - - - - - - -    
    def max_y
    # - - - - - - - - - - - - - - - -
       @max_y
    end #meth

    # - - - - - - - - - - - - - - - -    
    def min_y
    # - - - - - - - - - - - - - - - -
       @min_y
    end #meth

    
    # - - - - - - - - - - - - - - - -    
    def focus_y(focus_point=nil)
    # - - - - - - - - - - - - - - - -
      if (focus_point != nil)
        @focus_y = focus_point
        @max_y   = depth_off + calc_y(max_x, focus_point)
      end
      @focus_y
    end #meth
     
    
    
    # - - - - - - - - - - - - - - - -    
    def width(aWidth=nil)
    # - - - - - - - - - - - - - - - -
      if (aWidth != nil)
        @width = aWidth
        half_width = aWidth / 2
        @max_x = half_width
        @min_x  = 0 - half_width
        @max_y   = depth_off + calc_y(@max_x, @focus_point)
      end
      @width
    end #meth
    

    # - - - - - - - - - - - - - - - -    
    def calc_y(x_in, fp_in=@focus_y)
    # - - - - - - - - - - - - - - - -
      lcy  = calc_parab_y(x_in, fp_in)
      lcy
    end #meth
	
	
    # mill the arc in layers accordiing to the
    # maximum flute length
    # - - - - - - - - - - - - - - - -      
    def mill_arc(aDepth = @depth)
    # - - - - - - - - - - - - - - - -    	
	  print "(mill.cut_depth_inc=", @mill.cut_depth_inc,")\n"	  
      @mill.retract() 	  
	  dd = 0
      while true		  
	      dd -= (@mill.cut_depth_inc * 1.8)
		  if (dd < aDepth)
            dd = aDepth
          end #if          
          mill_arc_s(dd)
          if (dd <= aDepth)
            break
          end #if          
      end #while      
    end #meth
       
    # - - - - - - - - - - - - - - - -      
    def mill_arc_s(aDepth)
    # - - - - - - - - - - - - - - - -    
      x =  min_x      
      start_depth = aDepth + (@mill.cut_depth_inc * 0.75)         
      # Assumes layered caller will take mill bit
      # depth * 1.5 so we take 0.75 in first pass 
      # and the rest on the reverse pass. 		
	  # Had to add because milling in the negative
	  # on the Z axis.
      first_y = calc_y(x, @focus_y)
      @mill.move_fast(x, first_y, cz)
      @mill.plung(start_depth)
      # Mill Off Material around the Prabola
      set_speed_rough()
      x = @min_x
	  print "(Begin Parabola pass)\n"      

        while x <= @max_x
          y = calc_y(x, @focus_y)
          @mill.move(x,y)      
          x = x + @x_increment
        end #while
        
        print "(Reverse parabola pass)\n"       
        x = max_x
		@mill.plung(aDepth)
        while x >= @min_x
          y = calc_y(x, @focus_y)          
          @mill.move(x, y)
          x = x - @x_increment
        end #while
      
    end #meth

    
    # - - - - - - - - - - - - - - - -      
    def mill_focus_lines    
    # - - - - - - - - - - - - - - - -        
      set_speed_rough()
	  
	  print "(draw bottom parabola focus line)\n"
	  @mill.retract
      @mill.plung(-0.1)
	  @mill.move(@min_x, 0)
	  @mill.move(@max_x, 0)	  	  
	  
      print "(draw vertical focus line up the center)\n"
  	  @mill.retract()
      @mill.move(0, 0)
      @mill.plung(-0.1)
      @mill.move(0, @mill.max_y)

      print "(Draw Horizontal line through focus point)\n"
      set_speed_rough()
      @mill.retract() 
      @mill.move_fast(@min_x, @focus_y_bit_adj)
      @mill.plung(-0.1)
      @mill.move(@max_x, @focus_y_bit_adj)
      @mill.retract()
	  
	  print "(Draw horizontal cut off line)\n"
      set_speed_rough()
      @mill.retract() 
      @mill.move_fast(@max_x, @max_y)
      @mill.plung(-0.1)
      @mill.move(@min_x, @max_y)
      @mill.retract()
	  
    end #meth
	
	# - - - - - - - - - - - - - - - -        
	def mill_align_holes
	# - - - - - - - - - - - - - - - -        
      print "(min_y=", @min_y, " max_y = ", @max_y, " align_y=",  @align_y, ")\n"      
      print "(Mill  horizontal right alignment hole)\n"
	  @mill.retract()	  
      aCircle = CNCShapeCircle.new(@mill)
      aCircle.mill_pocket(0 + @align_x_offset, @focus_y_bit_adj, @align_hole_diam,  @depth)
      @mill.retract()
      set_speed_rough()

      print "(Mill horizontal left alignment hole)\n"
	  @mill.retract()
      aCircle = CNCShapeCircle.new(@mill)
      aCircle.mill_pocket(0 - @align_x_offset, @focus_y_bit_adj,  @align_hole_diam,   @depth)
      @mill.retract()
      set_speed_rough()
	  
      print "(Mill vertical align Holes above focus point)\n"
	  minay = @focus_y_bit_adj + @focus_diam +  @align_hole_diam
	  ay = @max_y 
	  while ay >= minay
	    aCircle.mill_pocket(0, ay, @align_hole_diam, @depth)
		ay -= @align_hole_diam * 3
	  end #while	
	  
	  print "(Mill vertical align holes below focus point)\n"
	  minay = @align_hole_diam * 2
	  ay = @focus_y_bit_adj - (@focus_diam +  @align_hole_diam)
	  while ay >= minay
	    aCircle.mill_pocket(0, ay, @align_hole_diam, @depth)
		ay -= @align_hole_diam * 3
	  end # while
  
	end #meth
      
	# - - - - - - - - - - - - - - - -        
	def mill_focus_hole
	# - - - - - - - - - - - - - - - -        
      print "(Mill out Center Aiming Axel hole)\n"
	  print "(focus_diam=", @focus_diam, " focus_y=", @focus_y, " depth=", @depth, ")\n"
      @mill.retract()
      aCircle = CNCShapeCircle.new(@mill)
      aCircle.mill_pocket(0, @focus_y_bit_adj, @focus_diam, @depth)
      @mill.retract()
      set_speed_rough()
	end #meth

	# - - - - - - - - - - - - - - - -        
	def mill_cut_off_sides
	# - - - - - - - - - - - - - - - -        	  
	  print "(Cut off Left Side)\n"
      @mill.retract()
      @mill.cut_off(
          @min_x,
		  @min_y,
          0.1, 
          @min_x , 
          @mill.max_y, 
          @depth)		 

	  print "(Cut of Right Side)\n"
	  @mill.retract()	  
      @mill.cut_off(
          @max_x,
		  @min_y,
          0.1, 
          @max_x , 
          @mill.max_y, 
          @depth)
      @mill.retract()
	end #meth
     
		
    # - - - - - - - - - - - - - - - -      
    def do_mill_end_plate_pattern    
    # - - - - - - - - - - - - - - - -        
      # # # # # # # #
      # # # BEGIN MAIN
      # # # # # # # # 
      aRect =  CNCShapeRect.new(@mill)        
      align_y =  @focus_y
	  mill_focus_lines()
	  mill_align_holes()
	  mill_focus_hole()
	        
      print "(Mill out the actual Arc)\n"
      mill_arc(@depth)  
      @mill.retract()
      set_speed_rough()

	  if @cut_off_sides == true
	    @mill.retract()
        mill_cut_off_sides()
	    @mill.retract();
	  end #if
	  
      # Move table to home position for next
      # milling operation
      @mill.home()
   
    end #meth
  end #class
