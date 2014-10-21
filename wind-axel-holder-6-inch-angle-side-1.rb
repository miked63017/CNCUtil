#  Mill bearing holder for smaller wind turbine.  This involes 4 1/4"
# holes for bolts with a 3/4" indent for the bearing centered over
# a 5/8" hole to allow the axel to pass through. 


require 'CNCMill'
require 'CNCShapeCircle'



class Wind_Axel

  #   #   #   #   #   #   #   #   #
   def initialize(millIn)
   #   #   #   #   #   #   #   #   #
   #attr_accessor :mill, :material_x_len, :material_y_len, :math_thick, :cent_x, :cent_y, :bearing_model
   #attr_accessor :bearing_thick, :bearing_od_diam, :bearing_id_diam, :mount_diam, :mount_offset
   #attr_accessor :mount_offset, :max_bearing_sock_ratio,  :max_bearing_sock_depth
   @mill = millIn
   #@material_type = "wafer"
   @material_type = "abs"        # Use UHMW milling speeds
   #@material_type = "acrylic"
   #@material_type = "steel0.125" # 1/8" steel
      #@material_type = "uhmw"
   #@material_type = "1/8 X 1 steel angle"
   
   @material_x_len = 6.0
   @material_y_len = 1.0
   @material_thick=  0.126
   @mount_diam = 0.25 + 0.03 # Make a little larger to give positioning room
  @mount_offset = 1.0

  
   @cent_x = 0
  
   @bearing_model = '6200-2RSLC3'  # Fastenall

   if @bearing_model == '6200-2RSLC3'
    # FAstenall largest bearing just under 1/2" threaded size
    @bearing_thick =    0.375 # just hair under 3/8"
    @bearing_od_diam = 1.182 #1.1875  # 1 3/16" 
        # At 1.1875 the bearing slips in an out freely so reduced by 0.005
    @bearing_id_diam =   0.375 # 3/8"
   end


  @max_bearing_sock_ratio = 0.70
  
  @mill.job_start()

  @circle = CNCShapeCircle.new(@mill, @cent_x, @cent_y)
  @circle.beg_depth = 0

   recalc()
end #init

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def recalc()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # recalc main things like drill through depth,
  # center Y, etc based  on changed current parameters
  #
  print "(BEGIN RECALC)\n"
  
  # Bearig selection moved here to allow individual
  # routines to contain bearing name without
  # repeating bearing dimensions.
  if @bearing_model == '608-zz'  # Fastenal / Bearings Limited
	@bearing_thick =    0.275
        @bearing_od_diam = 0.867
           # At 1.1875 the bearing slips in an out freely so reduced by 0.005
        @bearing_id_diam =   0.312 
  elsif @bearing_model == '6200-2RSLC3'
      # FAstenall largest bearing just under 1/2" threaded size
      @bearing_thick =    0.375 # just hair under 3/8"
      @bearing_od_diam = 1.182 #1.1875  # 1 3/16" 
        # At 1.1875 the bearing slips in an out freely so reduced by 0.005
      @bearing_id_diam =   0.375 # 3/8"
  elsif @bearing_model == 'R1212-ZZ'  # 99 cent bearings 1/2" nominal ID thin
        # Slips nicely over 1/2" 20 TPI threaded rod
	# Not tight enough to prevent turning inside
	# the bearing.  Alternative is 5/8" bronze bushing.
	@bearing_thick       =    0.158
        @bearing_od_diam = 0.748           
        @bearing_id_diam   =    0.498
  elsif @bearing_model == '6201-zz' 
	# Fastenal / Bearings Limited
	# This bearing leaves some thread
        # on 1/2" threaded rod.	
	@bearing_thick =    0.275
        @bearing_od_diam = 1.245        
        @bearing_id_diam =   0.392
  end

  
  print "(bearing model=", @bearing_model, " thick=", @bearing_thick, " od=", @bearing_od_diam, " id=", @bearing_id_diam, ")\n"
  print "(material_thick=", @material_thick, ")\n"
  print "(material_type=",@material_type, ")\n"
  print "(material_x_len = ", @material_x_len, ")\n"
  print "(material_y_len = ", @material_y_len, ")\n"
   @cent_y = (@material_y_len / 2.0) + @mill.bit_radius

   @cent_y = (@material_y_len / 2.0) + @mill.bit_radius
        # Assumes the the bit is on the leading side and that
	# a postive movent in Y is needed to move from the side
	# into the edge.
	
  @max_bearing_sock_depth = 0 - (@material_thick* @max_bearing_sock_ratio)
  @bearing_depth = 0 - @bearing_thick
  @drill_through_depth = 0 - @material_thick
  @bearing_pass_diam = (@bearing_od_diam + @bearing_id_diam + @bearing_id_diam) / 3.0
  
  #print "(max_bearing_depth=", @max_bearing_sock_depth, " drill_through_depth=", @drill_through_depth, ")\n"
  #print "(bearing_pass_diam=", @bearing_pass_diam, ")\n"
  
  if @bearing_depth.abs > @max_bearing_sock_depth.abs
	# Make sure we leave enough material
	# to support our bearing
	@bearing_depth = @max_bearing_sock_depth	
  end

  print "(cent_y = ", @cent_y, ")\n"

end # meth recalc()


# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_square_mount_hole_pattern(mOffset)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Mill the mounting bolt holes
#    The mounting holes for the stator are a different
#     pattern than the frame mounting holes so
#     we can not use the primary 
  @mill.retract()
  @circle.mill_pocket(@cent_x - mOffset, @cent_y ,  @mount_diam, @drill_through_depth)
  @mill.retract()
  @circle.mill_pocket(@cent_x  + mOffset, @cent_y ,  @mount_diam, @drill_through_depth)
  @mill.retract()
  @circle.mill_pocket(@cent_x  , @cent_y + mOffset,  @mount_diam, @drill_through_depth)
  @mill.retract()
  @circle.mill_pocket(@cent_x  , @cent_y -  mOffset,  @mount_diam, @drill_through_depth)
  @mill.retract()
end


# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_main_mount_holes()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
  # The main mounting hole pattern is 4 holes
  # all in a line. along a 1" angle iron.
  @mill.retract()
  @circle.mill_pocket(@cent_x - @mount_offset * 2, @cent_y ,  @mount_diam, @drill_through_depth)
  @mill.retract()
  @circle.mill_pocket(@cent_x - @mount_offset, @cent_y ,  @mount_diam, @drill_through_depth)
  @mill.retract()
  @circle.mill_pocket(@cent_x  + @mount_offset, @cent_y ,  @mount_diam, @drill_through_depth)
  @mill.retract()
  @circle.mill_pocket(@cent_x  + @mount_offset*2, @cent_y ,  @mount_diam, @drill_through_depth)
  @mill.retract()
end 	

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_top_side_axel_holder()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
#  Assumes a 1" angle which  has a hole slightly larger than
# the axel through which the axel passes.  Also must 
# drill holes for the bearing support pads. 
@mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "steel")    
@mill.home()
@mount_offset = 1.0
recalc()
@cent_y = @cent_y - 0.05

# No bearing pocket needed on this unit.
# Mill the axel pass through hole
@circle.beg_depth = 0
@circle.mill_pocket(@cent_x, @cent_y, @bearing_pass_diam, @drill_through_depth)
@circle.beg_depth = 0

# Just mark the drilling points to save the bit
@drill_through_depth = @drill_through_depth / 10
# Mill the mounting bolt holes
mill_main_mount_holes()
@mill.home()
@mill.job_finish()	
end


# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_frame_side_axel_holder()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Assumes a 1" angle into which we must drill the
#  holes which anchor the axel holder to the frame.
# These holes are intentionally offset to not conflict
#  with the holes for the bearing support pad. 
@mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "steel")    
@mill.home
 @mount_offset = 1.3
@circle.beg_depth = 0
recalc()
@cent_y = @cent_y - 0.05
# Just mark the drilling points to save the bit
@drill_through_depth = @drill_through_depth / 10

mill_main_mount_holes()
@mill.home()

@mill.job_finish()
end



# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_bearing_support_pad()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # The bearing support pad is sometimes called the bearing holder
  # It is normally  a piece of plastic into which a cavity it milled 
  #  to hold the bearing.   These pads have 4 holes 2 on each side
  #  of the axel hole which match the holes in the axel support bar. 
  @mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "uhmw")    
  @mount_diam = 0.245 # Can not make smaller because using 1/4" bit
  @mount_offset = 1.0
  @circle.beg_depth = 0
  @material_y_len = 2.0
  @material_thick=  0.390 # 0.375 # 3/8" UHMW cut from sheet
  @cent_x = 0
  recalc()

  print "(bearing_depth=", @bearing_depth, " material_thick=", @material_thick,  "bearing_thick=", @bearing_thick, ")\n"

  if 1 == 1
    # Mill the bearing pocket
    @circle.mill_pocket(@cent_x, @cent_y, @bearing_od_diam,  @bearing_depth)
    # Mill the axel pass through hole
    @circle.beg_depth = @bearing_depth
    @circle.mill_pocket(@cent_x, @cent_y, @bearing_pass_diam, @drill_through_depth)
    @circle.beg_depth = 0
    @mill.retract()
  end

  @mill.retract()
  mill_main_mount_holes()
  @mill.retract()
  @mill.home()
  @mill.job_finish()
end # mill_bearing_support_pad()


# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_bearing_support_pad_center_bottom()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # The center bearing support pad is milled to contain a
  # 1/2" shaft which allows the center axel to pass without 
  # the threads being turned off.  It is nominally 1/2" bearing.
  # It's purpose is simply to prevent any lateral play on the axel
  # which could flex under high wind loads.  This prevents the
  # axel from moving the rotor and causing it to collide with the
  
  #   This is a two part bearing holder the top which and bottom to hold
  # the bearing in place inspide of the fact that there is no weight on the
  # bearing.   Without this the bearing can ride up on the shaft.  The alternative
  # is to use a nut on the top but that would present greater risk of drag. 
  @mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "uhmw")    
  @bearing_model = 'R1212-ZZ'
  @mount_diam = 0.250 # Can not make smaller because using 1/4" bit
  @mount_offset = 1.0
  @circle.beg_depth = 0
  @material_y_len = 2.0
  @material_thick=  0.250 # 1/4 Derlin or Acrylic
  @max_bearing_sock_ratio = 0.75
  @cent_x = 0
  recalc()

  print "(bearing_depth=", @bearing_depth, " material_thick=", @material_thick,  "bearing_thick=", @bearing_thick, ")\n"
  
  # Mill the bearing pocket
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_od_diam,  @bearing_depth)
  # Mill the axel pass through hole
  @circle.beg_depth = @bearing_depth
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_pass_diam, @drill_through_depth)
  @circle.beg_depth = 0
  @mill.retract()
  

  @mill.retract()
  mill_main_mount_holes()
  @mill.retract()
  @mill.home()
  @mill.job_finish()
end # mill_bearing_support_pad()


# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_bearing_support_pad_center_top()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # The center bearing support pad is milled to contain a
  # 1/2" shaft which allows the center axel to pass without 
  # the threads being turned off.  It is nominally 1/2" bearing.
  # It's purpose is simply to prevent any lateral play on the axel
  # which could flex under high wind loads.  This prevents the
  # axel from moving the rotor and causing it to collide with the
  
  #   This is a two part bearing holder the top which and bottom to hold
  # the bearing in place inspide of the fact that there is no weight on the
  # bearing.   Without this the bearing can ride up on the shaft.  The alternative
  # is to use a nut on the top but that would present greater risk of drag. 
  @mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "uhmw")    
  @bearing_model = 'R1212-ZZ'
  @mount_diam = 0.250 # Can not make smaller because using 1/4" bit
  @mount_offset = 1.0
  @circle.beg_depth = 0
  @material_y_len = 2.0
  @material_thick=  0.250 # 1/4 Derlin or Acrylic
  @max_bearing_sock_ratio = 0.18
  @cent_x = 0
  recalc()

  print "(bearing_depth=", @bearing_depth, " material_thick=", @material_thick,  "bearing_thick=", @bearing_thick, ")\n"
  
  # Mill the bearing pocket
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_od_diam,  @bearing_depth)
  # Mill the axel pass through hole
  @circle.beg_depth = @bearing_depth
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_pass_diam, @drill_through_depth)
  @circle.beg_depth = 0
  @mill.retract()
  

  @mill.retract()
  mill_main_mount_holes()
  @mill.retract()
  @mill.home()
  @mill.job_finish()
end # mill_bearing_support_pad()



# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_stator_bearing_holder ()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  print "(Mill_stator_bearing_holder)\n"
  @mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "uhmw")    
  @mill.home
  @mount_offset = 2.0
  @circle.beg_depth = 0
  @material_x_len = 6.0
  @material_y_len = 5.0
  
  @cent_x = 0
   
  if @material_type == "wafer"
	@material_thick= 0.422
  elsif @material_type == "uhmw"
	@material_thick = 0.385
  elsif @material_type == "acrylic"
        @material_thick=  0.220  	
  elsif @material_type == "abs"
        @material_thick = 0.252
  else
	@material_thick=  0.220  
  end #if
  
  recalc()
  
   
  # Mill the bearing pocket
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_od_diam,  @bearing_depth)
  # Mill the axel pass through hole
  @circle.beg_depth = @bearing_depth
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_pass_diam, @drill_through_depth)
  @circle.beg_depth = 0
  mill_square_mount_hole_pattern(@mount_offset)

  # Trace circles on mounting holes
  # cut 90% of way through outside diam
  @cut_out_diam = (@mount_offset * 2) + (@mount_diam * 4)
  @cut_out_radius = @cut_out_diam / 2.0
  @start_y = @cent_y - @cut_out_radius

  @mill.move(@cent_x, @start_y)
  mill_circle(@mill, @cent_x,@cent_y, @cut_out_diam, @beg_depth=0, depth=@drill_through_depth * 0.95, adjust_for_bit_radius=true)
  @mill.retract()
  @mill.home()
  @mill.job_finish()
end



# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_quick_stator_bearing_holder ()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  print "(Mill_stator_bearing_holder)\n"
  @mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "wood")    
  @mill.home
  @mount_offset = 2.0
  @circle.beg_depth = 0
  @material_x_len = 6.0
  @material_y_len = 5.0
  @bearing_model = '608-zz'  # Will reset bearing diam in recalc()
        # At 1.1875 the bearing slips in an out freely so reduced by 0.005
  @cent_x = 0
  @material_thick= 0.575  # CDX plywood but better to use plastic.
  
  recalc()
  
  @cent_y = @mount_offset + @mount_diam + (@mill.bit_diam * 2) 
  print "(new cent_y=", @cent_y, ")\n"
   
  # Mill the bearing pocket
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_od_diam,  @bearing_depth)
  # Mill the axel pass through hole
  @circle.beg_depth = @bearing_depth
  @circle.mill_pocket(@cent_x, @cent_y, @bearing_pass_diam, @drill_through_depth)
  @circle.beg_depth = 0
  
  # Don't want to pay the time to mill the mounting
  # holes and cutout all the way through so instead
  # pretend the material is 1/15 as thick so we can see
  # where they would be but not affect structural strength.
  #@material_thick = @material_thick / 15
  #recalc()

  mill_square_mount_hole_pattern(@mount_offset)


  # Trace circles on mounting holes
  # cut 90% of way through outside diam
  @cut_out_diam = (@mount_offset * 2) + (@mount_diam * 4)
  @cut_out_radius = @cut_out_diam / 2.0
  @start_y = @cent_y - @cut_out_radius

  @mill.move(@cent_x, @start_y)
  mill_circle(@mill, @cent_x,@cent_y, @cut_out_diam, @beg_depth=0, depth=@drill_through_depth * 0.95, adjust_for_bit_radius=true)
  @mill.retract()
  @mill.home()
  @mill.job_finish()
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
def mill_frame_side_support()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Assumes a 1" angle that is 10" long welded onto the side of the 
#  frame which provides holes  to  frame upright with simple lag
# screws.  

  @mill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "steel")    
  @mill.home
  @material_x_len = 6.0
  @mount_offset = 2.5
  #@mount_diam = 0.245 # 1/4 " drilled holes
  @material_thick=  0.132 # 1/8" with a bit extra
  recalc()

  @circle.beg_depth = 0
  @circle.mill_pocket(@cent_x, @cent_y, @mount_diam, @drill_through_depth)
  mill_main_mount_holes()
  @mill.retract()
  @mount_offset = 0.6
  recalc()
  mill_main_mount_holes()

  @mill.home()
  @mill.job_finish()
end


end # class


main = true
if main == true
  @mill = CNCMill.new
  aWindAxel = Wind_Axel.new(@mill)

	
  main_opt = 2



  if main_opt == 1 
     aWindAxel.mill_top_side_axel_holder()
  elsif main_opt == 2
    aWindAxel.mill_frame_side_axel_holder()
  elsif main_opt == 3
    aWindAxel.mill_bearing_support_pad()
 elsif main_opt == 4
    aWindAxel.mill_bearing_support_pad_center_bottom()
  elsif main_opt == 4.2
    aWindAxel.mill_bearing_support_pad_center_top()
  elsif main_opt == 5
     aWindAxel.mill_stator_bearing_holder()
  elsif main_opt == 6
     aWindAxel.mill_frame_side_support()
  elsif main_opt == 7
     aWindAxel.mill_quick_stator_bearing_holder()
  end

end # main
