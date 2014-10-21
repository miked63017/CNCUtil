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
def  arc_pocket_adv(
   mill, 
   pCirc_x,
   pCirc_y,
   pBeg_min_radius,
   pBeg_max_radius,  
   pBeg_angle,
   pEnd_min_radius, 
   pEnd_max_radius, 
   pEnd_angle,  
   pDepth = nil,
   pDegree_inc = nil)
# - - - - - - - - - - - - - - - - - - - -
    # print "(arc_segment_pocket pDepth=", pDepth, ")\n"

    aArc = CNCShapeArcPocketAdv.new(
                          mill, pCirc_x,
                          pCirc_y,
                          pBeg_min_radius, 
                          pBeg_max_radius,  
                          pBeg_angle, 
                          pEnd_min_radius, 
                          pEnd_max_radius, 
                          pEnd_angle,                            
                          pDepth,
                          pDegree_inc)
    aArc.beg_depth = mill.cz 
    if aArc.beg_depth > 0
      aArc.beg_depth = 0
    end                                        
    aArc.do_mill()
    return aArc
end #meth



  # *****************************************
  class CNCShapeArcPocketAdv
  # *****************************************
    include  CNCShapeBase
    extend  CNCShapeBase
    
    attr_accessor :beg_min_radius, :beg_max_radius, :beg_angle, :end_min_radius, :end_max_radius, :end_angle, :degree_inc, :depth, :needs_check_parms
    
    #attr_writer :duration
    #attr_reader :name, :artist, :duration

    # - - - - - - - - - - - - - - - - - - 
    def initialize(mill,  x,  y,  
        pBeg_min_radius,   pBeg_max_radius, pBeg_angle=0,
        pEnd_min_radius=nil, pEnd_max_radius=nil, pEnd_angle=360,
        pDepth=nil,  pDegree_inc=nil
        )
    # - - - - - - - - - - - - - - - - - -
    
      base_init(mill,x,y,nil,pDepth)
      @beg_min_radius  = pBeg_min_radius
      @beg_max_radius  = pBeg_max_radius
      @beg_angle       = pBeg_angle
      @end_min_radius  = pEnd_min_radius
      @end_max_radius  = pEnd_max_radius
      @end_angle       = pEnd_angle   
      @degree_inc      = pDegree_inc
      @depth           = pDepth
      @needs_check_parms = true

      #print "(CNCShapeArc init pDepth=", pDepth,  " @pDepth=", @pDepth, ")\n"
      #check_parms
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
    if (@needs_check_parms == false)
      return false # didn't need to run
    else
      @needs_check_parms = false
      # reset flag so we don't keep
      # adjusting the parms which would
      # keep deducting the pRadius from
      # them.
    end #if

    # Swap if needed to make sure min
    # really is smallest on beginning
    if (@beg_min_radius > @beg_max_radius)
      tt = @beg_min_radius
      @beg_min_radius = @beg_max_radius
      @beg_max_radius = tt
    end #if

    # swap if needed to make sure
    # min really is smallest on 
    # beginning
    if (@end_min_radius > @end_max_radius)
      tt = @end_min_radius
      @end_min_radius = @end_max_radius
      @end_max_radius = tt
    end # if

    
    #print "(check_parms @beg_min_radius=", pBeg_min_radius, " bit_radius=", bit_radius,")\n"

    # Adjust for Bit pRadius
    @beg_min_radius   += bit_radius
    @end_min_radius   += bit_radius
    @beg_max_radius  -= bit_radius
    @end_max_radius  -= bit_radius
    return self
  end #meth

 

  # does the actual milling operation
  # and properly handels multiple passes
  # when milling deep pockets.
  # - - - - - - - - - - - - - - - - - - - -
  def  do_mill()
  # - - - - - - - - - - - - - - - - - - - -
    #print "(mill arc segment pocket pBeg_angle=", pBeg_angle,  "  pEnd_angle=",  pEnd_angle,   " pDepth = ", pDepth, " @pDepth=", @pDepth, ")\n"
    check_parms()
    bit_radius_half = bit_radius / 2
    beg_mid_radius = (beg_min_radius + beg_max_radius) / 2.0
    end_mid_radius = (end_min_radius + end_max_radius) / 2.0
    cut_inc = mill.cut_inc

    curr_depth = beg_depth
    if (curr_depth < 0)
      curr_depth = 0
    end #if
    
    lbeg_min_radius = beg_min_radius + mill.bit_radius
    lbeg_max_radius = beg_max_radius + mill.bit_radius
    
    if (mill.cz < beg_depth)
      mill.retract(beg_depth)
    end #if
    
    #mill.retract()
    while (true) # depth    
    #  print "(mill arc pocket curr_depth=", curr_depth,  " depth=", depth, ")\n"  
      cibr = beg_mid_radius - mill.cut_inc
      cier = end_mid_radius - mill.cut_inc
      cmbr = beg_mid_radius + mill.cut_inc
      cmer = end_mid_radius + mill.cut_inc      
      while(true) # radius
         next_depth = curr_depth - (mill.cut_depth_inc)
         if (next_depth < depth)
           next_depth = depth
           degree_per_step = 7.0           
         else
          degree_per_step = 1.0
         end
         
         
         if (cibr < beg_min_radius)
           cibr = beg_min_radius
         end #if
  
         if (cier < end_min_radius)
           cier = end_min_radius
         end # if
  
         if (cmbr > beg_max_radius)
           cmbr = beg_max_radius
         end
  
         if (cmer > end_max_radius)
           cmer =  end_max_radius
         end #if
  
         #cp = calc_point_from_angle(pcx,pcy, pBeg_angle, cibr)  
         #mill.move(cp.x, cp.y)
         #mill.plung(pDepth)
         
         
     
         changing_radius_curve(mill, 
           pcx = x,
           pcy = y,
           pBeg_radius = cibr,
           pBeg_angle  = beg_angle,  
           pBeg_z      = curr_depth,  
           pEnd_radius = cier, 
           pEnd_angle  = end_angle,
           pEnd_z      = next_depth,  
           pDegrees_per_step=degree_per_step, 
           pSkip_z_LT=nil, 
           pSkip_z_GT=nil,
           pAuto_speed_adjust= false)
         
         #changing_radius_curve(mill, 
         #  pcx = x,
         #  pcy = y,
         #  pBeg_radius = cier,
         #  pBeg_angle  = end_angle ,  
         #  pBeg_z      = next_depth,  
         #  pEnd_radius = cibr, 
         #  pEnd_angle  = beg_angle,
         #  pEnd_z      = next_depth,  
         #  pDegrees_per_step=degree_per_step, 
         #  pSkip_z_LT=nil, 
         #  pSkip_z_GT=nil,
         #  pAuto_speed_adjust= false)  
  
           
         #changing_radius_curve(mill, 
         #  pcx = x,
         #  pcy = y,
         #  pBeg_radius = cmbr,
         #  pBeg_angle  = beg_angle,  
         #  pBeg_z      = curr_depth,  
         #  pEnd_radius = cmer, 
         #  pEnd_angle  = end_angle,
         #  pEnd_z      = next_depth,  
         #  pDegrees_per_step=degree_per_step, 
         #  pSkip_z_LT=nil, 
         #  pSkip_z_GT=nil,
         #  pAuto_speed_adjust= false)
         #mill.retract(curr_depth)
         changing_radius_curve(mill, 
           pcx = x,
           pcy = y,
           pBeg_radius = cmer,
           pBeg_angle  = end_angle ,  
           pBeg_z      = next_depth,  
           pEnd_radius = cmbr, 
           pEnd_angle  = beg_angle,
           pEnd_z      = next_depth,  
           pDegrees_per_step=degree_per_step, 
           pSkip_z_LT=nil, 
           pSkip_z_GT=nil,
           pAuto_speed_adjust= false)  
           
         #changing_arc(mill, x,y,cibr, beg_angle, cier, end_angle, curr_depth, degree_inc)  # mill increasing
         #mill.retract()
         #changing_arc(mill, x,y,cmer, end_angle, cmbr, beg_angle, curr_depth, degree_inc)
         #mill.retract()  # mill decreasing
  
         if ((cibr <= beg_min_radius) &&
           (cier <=  end_min_radius) &&
           (cmbr >= beg_max_radius) &&
           (cmer >= end_max_radius))
             break
         end 
  
         cibr -= cut_inc
         cier -= cut_inc
         cmbr += cut_inc
         cmer += cut_inc
       end  #while radius
       
       if (next_depth == depth)
         break
       else
          curr_depth -= mill.cut_depth_inc
          if (curr_depth < depth)
            curr_depth = depth
          end
       end #else
        
     end #while depth
  

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


