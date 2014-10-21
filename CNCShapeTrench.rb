# CNCShapeTrench
# 
#  Allow a circular trench to be cut on the horizontal plane.
#
#
include Math
require 'CNCMill'
require 'CNCShapeRect'



 


# Mills a trench that runs along the X centered on the Y coordinate.
#  the horizontal calculations are stretched to by an adjustment to
#  allow wide shallow grooves.  Either or both ends can be beveled
#  from the circle calc point back to the beg_z to make plastic
#  molds easier.
#
#  The horizontal  coverage is stretched such that 
#   it is always actually that wide.  This is done by 
#   calculating a mathematical relationship between
#   the diameter and requested actual width and adusting
#   every postion calculation approapriatly
 # - - - - - - - - - - - - - - - - - -
 def mill_circ_trench_on_x_axis(mill, cent_y, bx,ex, diam, actual_width=-1, beg_z=-1,  bx_bevel_perc=0.0, ex_bevel_perc=0.0, adjust_for_bit_radius=false, degree_inc=3)
 # - - - - - - - - - - - - - - - - - -
    #print "mill circle x=", x, " y=", y, " diam=", diam, " depth=", depth, ")\n"
    print "(mill_circ_trench_on_x_axis diam= ", diam, ")\n"
    print "(cent_y=", cent_y, " beg x=", bx,  " end_x=", ex,  " beg depth=", beg_z, " degree_inc=", degree_inc, ")\n"
    print "(actual_width=", actual_width, ")\n"
    print "(bit_diam=", mill.curr_bit.diam, "  adjust_for_bit_radius=", adjust_for_bit_radius, ")\n"
    print "(bevel % on bx end=", bx_bevel_perc, " % on ex end=", ex_bevel_perc, ")\n"
    
    if (beg_z == -1)
      beg_z = mill.cz
   end
   
      
    if (diam < (mill.bit_diam / 4.0))
       print "(Warning mill_circ_trench with bits more than 0.2 the size diameter produce flat bottoms.  )\n"
       print "(half pipe diam=", diam, "bit diam = ", mill.bit_diam, ")\n"
       print "(can also cause very narrow grooves when auto adjusting for bit radius)\n"
    end #if
    
    if actual_width == -1 
      actual_width = diam
    end
	    
    if adjust_for_bit_radius == true
      bx = bx + mill.bit_radius
      ex = ex - mill.bit_radius
      actual_width = actual_width - mill.bit_diam
    end

    if degree_inc > 20
     print "(max degree inc is 20)\n"
     degree_inc = 20
    end
   


    curr_degree = 90
    end_degree = 180
    radius  =  diam / 2.0
    tot_line_len = ex - bx
    beg_bev_len  = tot_line_len * bx_bevel_perc
    end_bev_len   = tot_line_len * ex_bevel_perc

    print "(tot_line_len = ", tot_line_len,  " beg_bev_len=", beg_bev_len, " end_bev_len=", end_bev_len, ")\n"
    

    beg_circ_line = bx + beg_bev_len
    end_circ_line = ex - end_bev_len
    
    stretch_factor = actual_width / diam
    
    print "(horizontal stretch factor=", stretch_factor, ")\n"
    
    skip_center_radius = mill.bit_radius * 0.2
       # these would be simple over lap
       # passes anyway

    # Move the head to a good starting 
    # point. 
    mill.retract()
    mill.move_fast(bx, cent_y)
    mill.plung(beg_z)
    
    while (curr_degree < end_degree)
      curr_degree = curr_degree + degree_inc
      cp = calc_point_from_angle(0, beg_z, curr_degree, radius)
      # Normally point calc works by calculating X and Y coorinates around
      # a circle.   In this instances we will use the Y calculated as movement
      # on the Z plane instead.
      cp.x = cp.x.abs
      hpoint_rel = cp.x * stretch_factor	  
         # Note the bit adjustment is done
	 # automatically by the stretch factor
	 # which had the bit applied if needed
      pos_point = cent_y - hpoint_rel
      neg_point = cent_y + hpoint_rel
      
      if (hpoint_rel >=  skip_center_radius)
	  new_z =beg_z - cp.y.abs
	  mill.move(bx,  pos_point, beg_z) 
	      # Move to starting point for this pass
	  mill.move(beg_circ_line, pos_point, new_z)
	      # move down bevel 
	  mill.move(end_circ_line,pos_point, new_z)
	      # the actual milling of the circle
	  mill.move(ex, pos_point, beg_z)
	      # the bevel at the end
	  mill.move(ex, neg_point,beg_z)
	      # Move across to other side of trench
	  mill.move(end_circ_line, neg_point, new_z)
	      # mill the bevel down
	  mill.move(beg_circ_line,neg_point,new_z)
	      # mill the actual bottom of the circle trench
	   mill.move(bx, neg_point,beg_z)
	      # mill the bevel back up
     end # if
     
    end # while
    
    mill.retract()
end # method


# Mills a trench that runs along the X centered on the Y coordinate.
#  the horizontal calculations are stretched to by an adjustment to
#  allow wide shallow grooves.  Either or both ends can be beveled
#  from the circle calc point back to the beg_z to make plastic
#  molds easier.
#
#  The horizontal  coverage is stretched such that 
#   it is always actually that wide.  This is done by 
#   calculating a mathematical relationship between
#   the diameter and requested actual width and adusting
#   every postion calculation approapriatly
 # - - - - - - - - - - - - - - - - - -
 def mill_circ_trench_on_y_axis(mill, cent_x, by,ey, diam, actual_width=-1, beg_z=-1,  by_bevel_perc=0.0, ey_bevel_perc=0.0, adjust_for_bit_radius=false, degree_inc=3)
 # - - - - - - - - - - - - - - - - - -
    print "(mill_circ_trench_on_y_axis diam= ", diam, ")\n"
    print "(cent_x=", cent_x, " beg y=", by,  " end_y=", ey,  " beg z=", beg_z, " degree_inc=", degree_inc, ")\n"
    print "(actual_width=", actual_width, ")\n"
    print "(bit_diam=", mill.curr_bit.diam, "  adjust_for_bit_radius=", adjust_for_bit_radius, ")\n"
    print "(bevel % on by end=", by_bevel_perc, " % on ey end=", ey_bevel_perc, ")\n"
    
    if (beg_z == -1)
      beg_z = mill.cz
   end
   
   if degree_inc > 20
     print "(max degree inc is 20)\n"
     degree_inc = 20
   end
   
      
    if (diam < (mill.bit_diam / 4.0))
       print "(Warning mill_circ_trench with bits more than 0.2 the size diameter produce flat bottoms.  )\n"
       print "(half pipe diam=", diam, "bit diam = ", mill.bit_diam, ")\n"
       print "(can also cause very narrow grooves when auto adjusting for bit radius)\n"
    end #if
    
    if actual_width == -1 
      actual_width = diam
    end
	    
    if adjust_for_bit_radius == true
      bx = bx + mill.bit_radius
      ex = ex - mill.bit_radius
      actual_width = actual_width - mill.bit_diam
    end


    curr_degree = 90
    end_degree = 180
    radius  =  diam / 2.0
    tot_line_len = ey - by
    print "(tot_line_len=", tot_line_len, ")\n"
    beg_bev_len  = tot_line_len * by_bevel_perc
    end_bev_len   = tot_line_len * ey_bevel_perc
    print "(by bev_len=", beg_bev_len, " end_bev_len=", end_bev_len, ")\n"
    beg_circ_line = by + beg_bev_len
    end_circ_line = ey - end_bev_len
    
    stretch_factor = actual_width / diam
    
    print "(horizontal stretch factor=", stretch_factor, ")\n"
    
    skip_center_radius = mill.bit_radius * 0.2
       # these would be simple over lap
       # passes anyway

    # Move the head to a good starting 
    # point. 
    mill.retract()
    mill.move_fast(cent_x - radius, by)
    mill.plung(beg_z)
    
    while (curr_degree < end_degree)
      curr_degree = curr_degree + degree_inc
      cp = calc_point_from_angle(0, 0, curr_degree, radius)
      # Normally point calc works by calculating X and Y coorinates around
      # a circle.   In this instances we will use the Y calculated as movement
      # on the Z plane instead.
      cp.x = cp.x.abs
      hpoint_rel = cp.x * stretch_factor	  
         # Note the bit adjustment is done
	 # automatically by the stretch factor
	 # which had the bit applied if needed
      pos_point = cent_x  - hpoint_rel
      neg_point = cent_x + hpoint_rel
      
      if (hpoint_rel >=  skip_center_radius)
	  new_z =beg_z - cp.y.abs
	  mill.move(pos_point,  by, beg_z) 
	      # Move to starting point for this pass
	  mill.move(pos_point, beg_circ_line , new_z)
	      # move down bevel 
	  mill.move(pos_point,end_circ_line, new_z)
	      # the actual milling of the circle
	  mill.move(pos_point, ey, beg_z)
	      # the bevel at the end
	  mill.move(neg_point, ey,beg_z)
	      # move to oposite side of trench
	  mill.move(neg_point, end_circ_line, new_z)
	      # mill the bevel down
	  mill.move(neg_point,beg_circ_line,new_z)
	      # mill the actual bottom of the circle trench
	   mill.move(neg_point, by ,beg_z)
	      # mill the bevel back up
     end # if
      
    end # while
    
    mill.retract()
end # method


 # mill half pipe indention on X axis this is commonly used
 # to mill pipe entrance and exits
 # Maximum depth will be 1/2 specified diam

#  This area is formed by starting a circle and working around it in the Z Axis
#   To form  a 1 inch outlet area.   We have a string function which allows us
#   to calculate points on a curve even though we do not have a curve in the Z
#   Axis available in standard G code.    Once we work around the curve once
#   we can then move the bit forward by 3/4 diam and do it again
 # - - - - - - - - - - - - - - - - - -
 def mill_z_circ(mill, x,y, diam, beg_z=@cz,  adjust_for_bit_radius=false, beg_degree=90, end_degree=180)
 # - - - - - - - - - - - - - - - - - -
     #print "mill circle x=", x, " y=", y, " diam=", diam, " depth=", depth, ")\n"
    if (diam < (mill.bit_diam / 2.0))
       print "(Warning half pipe produces marginal results when bit is more than 1/2 size of circle)\n"
       print "(half pipe diam=", diam, "bit diam = ", mill.bit_diam, ")\n"
    end #if
    
    print "(mill_z_circ diam= ", diam, " bit_diam=", mill.curr_bit.diam, "  adjust_for_bit_radius=", adjust_for_bit_radius, ")\n"
      
    degree_inc  = 3
    curr_degree = beg_degree
    radius  =  diam / 2.0

    # Move the head to a good starting 
    # point. 
    mill.retract()
    mill.move_fast(x + radius, y)
    mill.retract(0)
    mill.set_speed(mill.speed / 15.0)

    while (curr_degree < end_degree)
      cp = calc_point_from_angle(0, beg_z, curr_degree, radius)
      cp.x = cp.x.abs
      if (cp.x >=  mill.bit_radius)
           # Then not just wasting movement
           # in the center.
          if (adjust_for_bit_radius == true)	
	    cp.x = cp.x - mill.bit_radius
          end	
  	  # not adjust for bit radius	  
 	  tx = x + cp.x
          mill.move(x + cp.x, y,  cp.y)
	  mill.move(x - cp.x, y,  cp.y)
     end # if
     curr_degree = curr_degree + degree_inc
    end # while
    
    mill.retract()
end # method


# mill half pipe indention on X axis this is commonly used
 # to mill pipe entrance and exits
 # Maximum depth will be 1/2 specified diam
#   
#  setting degree_inc to a higher number of degrees will optimize for speed but the 
#  resulting trench will be more rough.    Smaller number of degrees will be smoot but 
#  will take a lot longer.
#
#  Larger bit diameters result in a flat spot at the bottom of the tench equal to
#  the width of the bit being used.   Smaller bits or those with rounded tips provide
#  the best results.
# 
#  This area is formed by starting a circle and working around it in the Z Axis
#  To form  a circular trench which has the diameter specified.  The length
#   of the trench is on the Y axis while the curve is across the X axis.   The
#   For each degree caculated the system mills along the Y axis 
#
#   TODO:  Calculate the maximum depth of change based on cut depth increment
#    and if it is less than the depth of change due to degree increment then adjust
#    degree increment to reflect the lower values.
#
#   TODO:  Make an option that will rough out with much greater cuts than normal
#     but make the cut depth 1/10th more shallow than cut depth increment.  Then when
#     finished roughing out come back over it in the oposite directon using a depth first 
#     calculation moving from side to side.   This will provide a very nice finish and the finish
#     cuts can be done with 3/4 of a bit width so they will not take all that long.    

#
#    TODO:  Allow to be specfied on the X or Y axis rather than always trenching on the 
#    Y axis
#
#    TODO:  Allow the trench to be placed on tanget to any angle on the X Y plane so the
#    trench could be diagnal across the surface.
#
#
 # - - - - - - - - - - - - - - - - - -
 def mill_circ_trench_on_y_axis_v1(mill, x,beg_y, end_y,  diam, beg_z=@cz,  adjust_for_bit_radius=false, degree_inc=3)
 # - - - - - - - - - - - - - - - - - -
     #print "mill circle x=", x, " y=", y, " diam=", diam, " depth=", depth, ")\n"
    if (diam < (mill.bit_diam / 2.0))
       print "(Warning mill_circ_trench produces marginal results when bit is more than 1/2 size of circle)\n"
       print "(half pipe diam=", diam, "bit diam = ", mill.bit_diam, ")\n"
    end #if
    
    print "(mill_circ_trench diam= ", diam, " bit_diam=", mill.curr_bit.diam, "  adjust_for_bit_radius=", adjust_for_bit_radius, ")\n"
      
    curr_degree = 90
    end_degree = 180
    radius  =  diam / 2.0

    # Move the head to a good starting 
    # point. 
    mill.retract()
    mill.move_fast(x + radius, beg_y)
    mill.retract(0)
    while (curr_degree < end_degree)
      cp = calc_point_from_angle(0, beg_z, curr_degree, radius)
      # Normally point calc works by calculating X and Y coorinates around
      # a circle.   In this instances we will use the Y calculated as movement
      # on the Z plane instead.
            cp.x = cp.x.abs
      if (cp.x >=  mill.bit_radius)
           # Then not just wasting movement
           # in the center.
          if (adjust_for_bit_radius == true)	
	    cp.x = cp.x - mill.bit_radius
          end	
  	  # not adjust for bit radius	  
 	  tx = x + cp.x
	  new_z =beg_z - cp.y.abs
	  mill.move(x + cp.x, beg_y)
	  mill.plung(new_z)
          mill.move(x + cp.x, beg_y, new_z)
          mill.move(x + cp.x, end_y, new_z)
          mill.move(x -  cp.x, end_y, new_z)
	  mill.move(x -  cp.x,  beg_y,new_z)
	  mill.move(x + cp.x, beg_y, new_z)
     end # if
      curr_degree = curr_degree + degree_inc
    end # while
    
    mill.retract()
end # method



 # mill half pipe indention on X axis this is commonly used
 # to mill pipe entrance and exits
 # Maximum depth will be 1/2 specified diam

#  This area is formed by starting a circle and working around it in the Z Axis
#   To form  a 1 inch outlet area.   We have a string function which allows us
#   to calculate points on a curve even though we do not have a curve in the Z
#   Axis available in standard G code.    Once we work around the curve once
#   we can then move the bit forward by 3/4 diam and do it again
 # - - - - - - - - - - - - - - - - - -
 def mill_z_circ(mill, x,y, diam, beg_z=@cz,  adjust_for_bit_radius=false, beg_degree=90, end_degree=180)
 # - - - - - - - - - - - - - - - - - -
     #print "mill circle x=", x, " y=", y, " diam=", diam, " depth=", depth, ")\n"
    if (diam < (mill.bit_diam / 2.0))
       print "(Warning half pipe produces marginal results when bit is more than 1/2 size of circle)\n"
       print "(half pipe diam=", diam, "bit diam = ", mill.bit_diam, ")\n"
    end #if
    
    print "(mill_z_circ diam= ", diam, " bit_diam=", mill.curr_bit.diam, "  adjust_for_bit_radius=", adjust_for_bit_radius, ")\n"
      
    degree_inc  = 3
    curr_degree = beg_degree
    radius  =  diam / 2.0

    # Move the head to a good starting 
    # point. 
    mill.retract()
    mill.move_fast(x + radius, y)
    mill.retract(0)
    mill.set_speed(mill.speed / 15.0)

    while (curr_degree < end_degree)
      cp = calc_point_from_angle(0, beg_z, curr_degree, radius)
      cp.x = cp.x.abs
      if (cp.x >=  mill.bit_radius)
           # Then not just wasting movement
           # in the center.
          if (adjust_for_bit_radius == true)	
	    cp.x = cp.x - mill.bit_radius
          end	
  	  # not adjust for bit radius	  
 	  tx = x + cp.x
          mill.move(x + cp.x, y,  cp.y)
	  mill.move(x - cp.x, y,  cp.y)
     end # if
     curr_degree = curr_degree + degree_inc
    end # while
    
    mill.retract()
end # method

