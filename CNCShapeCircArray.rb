# cncShapeCircArray.rb
# Up until now most of the circular array functions have been built
# in to the basic object types so that shapes like cncShapePolygon knew
# how to produce an array of them selfs centered around an arbitrary point
# however cncShapeCircArray can produce a circular array of any cncShape that
# follows the basic cncShape X,Y protocol.
#
# TODO:  It needs to know how to rotate the shapes so that they can either
# be put out at the same angle they where originally defined or rotate them so
# that they keep the same orientation towards the outside of the circle.  This means
# that the basic shape protocol should support rotate function.  
#
#
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

require 'CNCMill'
require 'CNCBit'
require 'CNCMaterial'
require 'CNCShapeBase'


  # Take a circle object and mill a set of these 
  # objects around a specified point at a specified
  # radius at the specified # of degrees or steps
  # # # # # # # # # # # # # # # # 
  class CNCShapeCircArray
  # # # # # # # # # # # # # # # # 
    include  CNCShapeBase
    extend  CNCShapeBase
   # - - - - - - - - - - - - - - - -    
    def initialize(mill, circle)
    # - - - - - - - - - - - - - - - -    
      base_init(mill)
      @mill = mill
      @circle = circle
      @radius = 1.0
      @start_degree = 0.00
      @end_dgree = 359.99
      @degree_increment = 45.0
    end #if

      # - - - - - - - - - - - - - - - -     
      def circle(oi=nil)
      # - - - - - - - - - - - - - - - -     
          if (oi != nil)
            @circle = oi
          end #if
          return @circle
       end  # meth


      # - - - - - - - - - - - - - - - -     
      def radius(oi=nil)
      # - - - - - - - - - - - - - - - -     
          if (oi != nil)
            @radius = oi
          end #if
          @radius
       end  # meth


      # - - - - - - - - - - - - - - - -     
      def start_degree(oi=nil)
      # - - - - - - - - - - - - - - - -     
          if (oi != nil)
            @start_degree = oi
          end #if
          @start_degree
       end  # meth


      # - - - - - - - - - - - - - - - -     
      def end_degree(oi=nil)
      # - - - - - - - - - - - - - - - -     
          if (oi != nil)
            @end_degree = oi
          end #if
          @end_degree
       end  # meth


      # - - - - - - - - - - - - - - - -     
      def degree_increment(oi=nil)
      # - - - - - - - - - - - - - - - -     
          if (oi != nil)
            @degree_increment = oi
          end #if
          @degree_increment
       end  # meth
       

      # set the degree increment
      # so that the number of degrees
      # is sufficient to allow the specified
      # number of steps.
      # - - - - - - - - - - - - - - - -     
      def set_num_steps(numl)
      # - - - - - - - - - - - - - - - -     
          if (oi != nil)
            @circle = oi
          end #if
          @circle
       end  # meth


      # Return the number of degree sweep
      # between start and end. 
      # - - - - - - - - - - - - - - - -     
      def sweep()
      # - - - - - - - - - - - - - - - -     
         return (@start_degree - @end_degree).abs         
       end  # meth


      # Return the number of elements
      # that can be milled at the current
      # setting of start_degree,
      # end_degree and degree increment
      # - - - - - - - - - - - - - - - -     
      def num_steps()
      # - - - - - - - - - - - - - - - -     
         sweep /  degree_increment
       end  # meth

      # - - - - - - - - - - - - - - - -     
      def set_full_circle()
      # - - - - - - - - - - - - - - - -     
         start_degree = 0
         end_degree  = 359.999
         @self
       end  # meth
  end #class