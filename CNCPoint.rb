# CNCPoint.rb
#require 'cncGeometry'
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
class CNCPoint
  #   #   #   #   #   #   #   #   # - - 
  def initialize( xi = 0,  yi = 0,  zi = 0)
  #   #   #   #   #   #   #   #   # - -
    @x = xi
    @y = yi
    @z = zi
  end # meth

  #   #   #   #   #   #   #   #   #     
  def to_s
  #   #   #   #   #   #   #   #   #     
    return sprintf("point x=%10.4f,   y=%10.4f,   z=%10.4f", @x, @y, @z)
  end #meth

  #  return my internal x_y coordinates
  # as a polor coordinate with distance
  # and angle polar coordinates
  #   #   #   #   #   #   #   #   #     
  def to_ xy_cncPolar
  #   #   #   #   #   #   #   #   #     
     return conv_rectangular_to_polar(distance, angle)
  end # meth

  #   #   #   #   #   #   #   #   #     
  def x
  #   #   #   #   #   #   #   #   #     
    @x
  end  #meth
  
  #   #   #   #   #   #   #   #   #
   def x=(xi)
  #   #   #   #   #   #   #   #   #
    @x = xi
    self
  end  # meth

  #   #   #   #   #   #   #   #   #     
  def y
  #   #   #   #   #   #   #   #   #     
    @y
  end #meth
  
  #   #   #   #   #   #   #   #   #     
  def y=(yi)
  #   #   #   #   #   #   #   #   #     
      @y = yi
      self
  end  # meth

  
  #   #   #   #   #   #   #   #   #     
  def z
  #   #   #   #   #   #   #   #   #     
    @z
  end

  #   #   #   #   #   #   #   #   #     
  def z=(zi)
  #   #   #   #   #   #   #   #   #     
     @z = zi
     @z
  end  # meth
       

end # class



# A represneation of a Polar Coordinate
class CNCPolar
  #   #   #   #   #   #   #   #   # 
  def initialize(dist = 0,  angle_deg = 0)
  #   #   #   #   #   #   #   #   # 
    @dist = dist
    @angle = angle_deg
  end # meth

  #   #   #   #   #   #   #   #   #     
  def to_s
  #   #   #   #   #   #   #   #   #     
    return sprintf("polar dist=%10.4f,   angle=%10.4f", @dist, @angle)
  end #meth

  # convert my  internal distance and 
  # angle into a X,Y coordinate relative
  # to X=0, Y=0
  #   #   #   #   #   #   #   #   #     
  def to_cncPoint
  #   #   #   #   #   #   #   #   #     
     return conv_polar_to_rectangular(distance, angle)
  end # meth


  #   #   #   #   #   #   #   #   #     
   def dist(dist=nil)
  #   #   #   #   #   #   #   #   #     
          if (dist != nil)
            @dist = dist
          end #if
          @dist
       end  # meth

  #   #   #   #   #   #   #   #   #     
  def angle(angle=nil)
  #   #   #   #   #   #   #   #   #     
          if (angle != nil)
            @angle = angle
          end #if
          @angle
       end  # meth

end # class



