# CNCChapeArc
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'cncmill'
require 'cncBit'
require 'cncMaterial'
require 'cncShapeBase'
require 'cncGeometry'
require 'cncShapeArc'



# creates an object to create a 
# arc segment milled pocket
# and calls for the mill operation
# returns the object created so
# it can be re-used.
# - - - - - - - - - - - - - - - - - - - -
def  arc_segment_pocket(
   mill, 
   pCirc_x,
   pCirc_y,
   pBeg_radius,
   pEnd_radius,  
   pBeg_angle,
   pEnd_angle,  
   pBeg_z,
   pEnd_z,
   pDegree_inc = nil)
# - - - - - - - - - - - - - - - - - - - -
   #print "(arc pocket  pEnd_z = ", pEnd_z, ")\n"

    aArc = CNCShapeArcPocket.new(
                          mill, pCirc_x,
                          pCirc_y,
                          pBeg_radius, 
                          pEnd_radius,  
                          pBeg_angle, 
                          pEnd_angle,  
                          pEnd_z,
                          pDegree_inc)
    aArc.beg_depth = pBeg_z
    
    print "(arc_segment_pocket  x=", pCirc_x, " y=", pCirc_y, ")\n"
    
    
    if aArc.beg_depth > 0
      aArc.beg_depth = 0
    end                        
    aArc.do_mill()
    return aArc
end #meth





 # *****************************************
  class CNCShapeArcPocket
  # *****************************************
    include  CNCShapeBase
    extend  CNCShapeBase
    
    attr_accessor :beg_radius, :end_radius, :beg_angle, :end_angle, :degree_inc, :depth
    
    #attr_writer :duration
    #attr_reader :name, :artist, :duration

    # - - - - - - - - - - - - - - - - - - 
    def initialize(mill,  px,  py,  
        pBeg_radius,   pEnd_radius, pBeg_angle=0,
        pEnd_angle=360,
        pDepth=nil,  pDegree_inc=nil
        )
    # - - - - - - - - - - - - - - - - - -    
      base_init(mill,px,py,nil,pDepth)
      @beg_radius  = pBeg_radius
      @end_radius  = pEnd_radius
      @beg_angle   = pBeg_angle
      @end_angle   = pEnd_angle   
      @degree_inc  = pDegree_inc
      @depth       = pDepth
      return self
    end #meth

  # check_parms needs to be called 
  # whenever the min_max pRadius have
  # been changed.  Normally this is
  # only during reset or initialization
  # could not figure out how to get
  # the constructor to call it or would
  # have done automatically.  As it is
  # the constructor sets a flag and
  # any method that may need to have
  # bit_adjusted pRadius dimensions
  # should call check_parms.
  # - - - - - - - - - - - - - - - - - -
  def  check_parms
  # - - - - - - - - - - - - - - - - - -
   
    # Swap if needed to make sure min
    # really is smallest on beginning
    if (@beg_radius > @end_radius)
      print "(warning: arc pocket swapping radius)\n"
      tt = @beg_radius
      @beg_radius = @end_radius
      @end_radius = tt
    end #if

    # swap if needed to make sure
    # min really is smallest on 
    # beginning
    if (@beg_angle> @end_angle)
      print "(warning: arc pocket swapping angles)\n"
      tt = @beg_angle
      @beg_angle = @end_angle
      @end_angle = tt
    end # if

 
    
    
    return self
  end #meth

 

  # does the actual milling operation
  # and properly handels multiple passes
  # when milling deep pockets.
  # - - - - - - - - - - - - - - - - - - - -
  def  do_mill()
  # - - - - - - - - - - - - - - - - - - - -
    check_parms()
    
    print "(cncShapeArcPocket.do_mill  x=", x, " y=", y, ")\n"
    
    # Adjust our radius to reflect
    # the Bit Size.   If the radius
    # difference winds up to small we
    # get a simple Arc.
    lBegRadius = beg_radius + bit_radius
    lEndRadius = end_radius - bit_radius    
    if (lEndRadius < lBegRadius)
      print "(warning arc pocket ", lBegRadius, " was too narrow converting to simple arc)\n"
      lEndRadius = lBegRadius
    end

    
    if (mill.cz < beg_depth)
      mill.retract(beg_depth)
    end #if
    
    if (depth > depth)
      print "(warning arc pocket depth beginning depth is deeper than end depth doing nothing)\n"
      return      
    end
    
    curr_depth = beg_depth

    tSpeed = mill.speed()
    while (true) # depth    
      curr_radius = lBegRadius          
      next_depth = curr_depth - mill.cut_depth_inc
      if (next_depth < depth)
        next_depth = depth
        deg_per_step = 0.5
      else
        deg_per_step = 6
      end
      
      while(true) # radius
          # calculate the amount for each 
          # segment that we have to move
          # the bit inward to get the outside
          # arch dimension exactly at X degrees.
          adjust_degree = degrees_for_distance(curr_radius, mill.bit_radius)
          lBeg_angle = beg_angle + adjust_degree
          lEnd_angle = end_angle - adjust_degree
          if (lEnd_angle < lBeg_angle)
            print "(warning pocket angle sweep is too small for bit)\n"
            lBeg_angle = lEnd_angle
          end
          
          #print "(arch_pocket curr_depth=", curr_depth, " )\n (next_depth=", next_depth, " )\n  (curr_radius=", curr_radius,  " )\n  (lBeg_angle=", lBeg_angle,  " )\n (lEnd_angle=", lEnd_angle,              " )\n (max depth =", depth, ")\n"
          # Mill forward going down
          mill.set_speed(tSpeed)
          changing_radius_curve(mill, 
             pcx=x,pcy=y,
             pBeg_radius=curr_radius, 
             pBeg_angle=lBeg_angle,  
             pBeg_z = curr_depth,  
             pEnd_radius=curr_radius,
             pEnd_angle = lEnd_angle, 
             pEnd_z=next_depth,  
             pDegrees_per_step=deg_per_step,
             pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=true)
        
          # Mill back comming level
          mill.set_speed(tSpeed * 2.0)
          changing_radius_curve(mill, 
             pcx=x,pcy=y,
             pBeg_radius=curr_radius, 
             pBeg_angle=lEnd_angle,  
             pBeg_z = next_depth,  
             pEnd_radius=curr_radius,
             pEnd_angle = lBeg_angle, 
             pEnd_z=next_depth,  
             pDegrees_per_step=deg_per_step,
             pSkip_z_LT=nil, pSkip_z_GT=nil, pAuto_speed_adjust=true)
          
          
        
        if (curr_radius == lEndRadius)
          print "(finsihed radius pass)\n"
          break
        else
          curr_radius += cut_inc            
          if (curr_radius > lEndRadius)
            curr_radius = lEndRadius
          end
        end #else
        mill.retract(mill.cz + mill.cut_depth_inc)
        mill.set_speed(tSpeed)
      end  #while radius
       
      if (next_depth == depth)
        print "(finished depth ", depth, ")\n"
        break
      else
        curr_depth = next_depth
      end
     mill.set_speed(tSpeed)
     end #while depth
  
     mill.set_speed(tSpeed)
   end #meth



  # First pyiu define an arc segment to mill to describe the
  # first arc segment pyiu desire and then pyiu call this function
  # rather than  do_mill which will mill an array of these objects
  # where each one moves pDegree_inc further around the circle.
  # If pDegree_between is equal to 0 then it will be set to 1/2 
  # the sweep angle of the current object.  If the
  # pNum_elem is 0 then the the system will calculate it a the 
  # number that will fit in a 360 degree circle with the current
  # sweep (pEnd_angle - pBeg_angle) + a 1/2 sweep angle between
  # each item.
  # - - - - - - - - - - - - - - - - - - - -
  def circ_array(pNum_elem=nil, pDegree_between=nil)
  # - - - - - - - - - - - - - - - - - - - -
     curr_beg_angle   = @beg_angle
     curr_end_angle   = @end_angle
     sweep_angle      = @end_angle -  @beg_angle

     if (pDegree_between == nil)
       pDegree_between = sweep_angle / 2.0
       pDegree_between_specified = false
     else
       pDegree_between = 0.0 + pDegree_between
       pDegree_between_specified = true
     end #if
     

     # Determine the number of elements we
     # can have
     if (pNum_elem == nil) || (pNum_elem == 0)
       degree_inc = sweep_angle + pDegree_between
       pNum_elem  = Integer(360.0 / pDegree_inc)
     elsif (pNum_elem * sweep_angle) > 360
       max_ele = Integer(360 /sweep_angle)
       degree_inc = sweep_angle + pDegree_between
     end #if


     #pDegree_inc = 360.0   
     #Adjust space between to get even spacing
     #if (pDegree_between_specified == false)
     #  total_sweep = (sweep_angle * pNum_elem)
     #  extra_sweep = 360 - total_sweep
     #  pDegree_between = extra_sweep / (pNum_elem - 1)
     #  print "(recalced pDegree_between=", degree_betwee, ")\n"
     #end #if

     if (degree_between_specified == true)
       degree_inc = sweep_angle + pDegree_between
     else
       degree_inc = 360 / pNum_elem
     end #if

     # illustrate an easy way to get a
     # repeating array of arc pockets
     for ele_cnt in (1..pNum_elem) 
        @beg_angle = curr_beg_angle 
        @end_angle = beg_angle + sweep_angle
        do_mill()
        mill.retract()
        curr_beg_angle += degree_inc
        if (curr_beg_angle > 360)
          curr_beg_angle = curr_beg_angle % 360
        end #for
     end #for
  end #meth




end #class


