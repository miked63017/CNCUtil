#  The class used to describe basic job parameters such 
#  as the width, height and depth of the material being 
#  milled as well as the intentions for zeroing the material
#  at time of start.   This material is used to adjust the
#  machine paramters based on the material size.
#
#  JOB should be extended to include the
#    file name of the material and the
#    filename of the milling machine to be used.
#    so the mill would only receive the one file name.
#

require 'DynamicLoader'
require 'CNCMill'

class  CNCJob
  include  DynamicLoader
  extend  DynamicLoader
   
   def initialize(aMill, load_fi_name="config/job/0001.rb")
     @mill = aMill
     @width = 14 # x
     @height = 8 # Y
     @depth  = 3 # z
     @zero_x = 0
     @zero_y = 0
     @zero_z = 0
      
     #load_file(load_fi_name)
     
     end #initialize
  
  
  def width
    @width
  end
     
  def width=(aIn)
    @width = aIn
  end
  
  def depth
    @depth
  end     
  def depth=(aIn)
    @depth = aIn
  end
  
  def height
    return @height
  end
  
  def height=(aIn)
    @height=aIn
  end
  
  
  def zero_x
    return @zero_x
  end
  
  def zero_x=(aNum)
      @zero_x  = aNum
  end

  
  
  def zero_y
      @zero_y
  end
  
  def zero_y=(aNum)
      @zero_y  = aNum
  end


  def zero_z
      @zero_z
  end
   
  def zero_z=(aNum)
      @zero_z  = aNum
  end
  
  
  def zero_a
      @zero_a
  end
   
  def zero_a=(aNum)
      @zero_a  = aNum
  end

end #class

