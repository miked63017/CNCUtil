#   #   #   #   #   #   #   #   #
module Pump_centrifuge_monolithic_body
#   #   #   #   #   #   #   #   #

  # # # # # # # # # # # # # # # # # #
  #  The difusser exit is a sloping and increasing
  #  diameter area that exhaust to the next layer
  #  of the system. 
  # # # # # # # # # # # # # # # # # #
  def difusser_exit(pcx, pcy, beg_radius, end_radius, pBegZ, pEndZ)
  # # # # # # # # # # # # # # # # # #
  
  end

  # # # # # # # # # # # # # # # # # #
  #  The monolithic body assumptions are that
  #  the main portion of the body with the exit
  #  to the next layer are in this portion of 
  #  the body. The main body would normallay 
  #  have an increasing diameter diffuser and
  #  an exit volute.   This versioin has the
  #  difusser that mimics the structure of the
  #  simple wheel but with the difusser vanes
  #  going in the oposite direction from the wheel
  #  The diffusser vanes area start at level of the
  #  top of the blade and slope downwards in addition
  #  to expanding which allows them to eventually exit
  #  into the layer. Since the diffuser directly exits
  #  to the next layer we do not need the exit volute
  #  In this design bearing socket is at the bottom of 
  #  the blade area and the wheel has 0.05 clearance
  #  from the bottom of blade to bottom of the chamber.
  #  The shaft is allowed to penetrate the bottom but the
  #  
  # # # # # # # # # # # # # # # # # #
  def monolithic_body()
  # # # # # # # # # # # # # # # # # #
    curr_depth = 0
    
    
    mill_impeller_outline_normal(pBegZ=0, pEndZ=nil)
    
    aMill.retract() 
     aCircle.beg_depth = pBegZ
     aCircle.mill_pocket(pcx, pcy, 
       cavity_diam + 0.3, 
       pEndZ, 
       island_diam=hub_diam)  
     aMill.retract(pBegZ)  
     
    mill_bearing_socket_common(pcx, pcy, pBegZ, pEndZ)
    mill_axel_normal
    mill_bolts_normal(0, drill_through_depth)
  end # meth
  
  
   # # # # # # # # # # # # # # # # # #
  def monolithic_lid(pCentX, pCentY)
   # # # # # # # # # # # # # # # # # #
   mill_bearing_socket_mirrored(pBegZ=0, pEndZ=nil)
   mill_bolts_mirrored(pBegZ=0, pEndZ=nil)
  end  # meth
  
  
  
   # # # # # # # # # # # # # # # # # #
  #  The most simple possible Monolithic
  #  centrifuge pump body which includes 
  #  a simple diffuser and side outlet. 
  #  have an increasing diameter diffuser and
  #  an exit volute.   This versioin has the
  #  difusser that mimics the structure of the
  #  simple wheel but with the difusser vanes
  #  going in the oposite direction from the wheel
  #  The diffusser vanes area start at level of the
  #  top of the blade and slope downwards in addition
  #  to expanding which allows them to eventually exit
  #  into the layer. Since the diffuser directly exits
  #  to the next layer we do not need the exit volute
  #  In this design bearing socket is at the bottom of 
  #  the blade area and the wheel has 0.05 clearance
  #  from the bottom of blade to bottom of the chamber.
  #  The shaft is allowed to penetrate the bottom but the
  #  
  # # # # # # # # # # # # # # # # # #
  def monolithic_body_simple()
  # # # # # # # # # # # # # # # # # #
    hub_nut_thick
    socket_depth = wheel_thick
  
    mill_impeller_outline_normal(0, wheel_thick)
    mill_bearing_socket_common(pcx, pcy, pBegZ, pEndZ)
    mill_axel_normal()
    
    diffuser_beg_diam = cavity_diam + air_gap
    diffuser_end_diam = diffuser_beg_diam + 0.3
    diffuser_air_gap_beg = diffuser_end_diam + mill.bit_diam
    diffuser_air_gap_end = diffuser_air_gap_beg + 0.25
    
    # Mill out air exit channel on outside
    # of diffuser.
    aMill.retract() 
     aCircle.beg_depth = 0
     aCircle.mill_pocket(pcx, pcy, 
       diffuser_end_diam + mill.bit_diam, 
       pEndZ, 
       island_diam=hub_diam)  
     aMill.retract(pBegZ)  
     
    
    mill_bolts_normal(0, drill_through_depth)
  end
  
  
  
  
end # module
