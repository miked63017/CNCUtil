#  The class used to describe basic machine parameters
#  and to dynamically load the machine configuration
#  settingings.

require 'DynamicLoader'
require 'CNCMill'

class  CNCMachine
  include  DynamicLoader
  extend  DynamicLoader
   
   def initialize(aMill, load_fi_name="config/machine/taig-2019.rb")
     @mill        = aMill
     @max_x_move  = 0
     @min_x       = 0
     @max_x       = 0
     @max_y       = 0
     @min_y       = 0
     @max_z       = 0
     @min_z       = 0
     
     
      @spindle_rpm = []
       # RPM of spindel in Taig 2019 with belt positions starting
       # at the top and working towards the bottom.  This mill
       # seems to have a problem reaching full speed in the highest
       # position while all others seem to work OK.  These numbers are used
       # to calculate what belt postion to request based on the work material
       # and bit being used


     #@fpm = []
       # This array maps the different F speeds to
       # Feet per min for the given mill, controller
       # stepper motor combination.  This is used 
       # to map our calculations
       # for optimal feed rates into an approapriate feed.

     @ipm = [] 
       # Inches per minute at various F speeds
       # calculated from test_speed.
       
     @ips =[]
       # inches per second at various F speeds.
       # calcualted from test_speed and test_speed_fract
       
     @fspeed =[]
       # The FSPEED used to derive this inch per second
       # rating.  This is used to determine 

     #
     @test_speed_fract=[] 
       # speeds at 0.1 through 1.0 needed for very slow
       # operations.   Postion one in this instance is
       # showing that it took 609 seconds to move 1 inch
       # at 0.1F and 202 seconds to move the same inche
       # at 0.3F.
       
     @test_speed = []
       # empiracle test of speed of mill to move
       # the X,Y axis one inch
       # at the same time.  Starting in F1 
       # working up through F20 results are in 
       # number of seconds required for the move. 
       # This value is used to create a speed of 
       # feet per minute for the various feed speeds
      
       load_file(load_fi_name)
        
       
       cc = 0
       for aNoSec in @test_speed_fract
         cc += 0.1
         inch_per_sec  = 1.0 / Float(aNoSec)
         inch_per_min  = inch_per_sec * 60.0
         feet_per_min = inch_per_min / 12.0
         #@fpm.push(feet_per_min)
         @ipm.push(inch_per_min)
         @ips.push(inch_per_sec)
         @fspeed.push(cc)
         #print "(F", cc, "  IPS=", inch_per_sec, " FPM=", feet_per_min, " test speed=", aNoSec,")\n"
       end #for
       
       # computer inches per minute movement at
       # various F speeds.
       cc = 0
       for aNoSec in @test_speed
         cc += 1
         inch_per_sec  = 1.0 / Float(aNoSec)
         inch_per_min  = inch_per_sec * 60.0
         feet_per_min = inch_per_min / 12.0
         #@fpm.push(feet_per_min)
         @ipm.push(inch_per_min)
         @ips.push(inch_per_sec)
         @fspeed.push(cc)
         #print "(F", cc, "  IPS=", inch_per_sec,  " IPM=", inch_per_min, "  FPM=", feet_per_min, " test speed=", aNoSec,")\n"
       end #for
       
       #print "ips=", @ips, "\nfspeed=", @fspeed,"\n"
     end #initialize
   
  def spindle_rpm=(aIn)
    @spindle_rpm = aIn
    return self
  end
  
  #def fpm=(aIn)
  #  @fpm = aIn
  #  return self
  #end
  
  
  #def ipm=(aIn)
  #  @ipm = aIn
  #  return self
  #end
  
  #def fspeed=(aIn)
  #  @fspeed = (aIn)
  #end
  
  def test_speed_fract=(aIn)
    @test_speed_fract = aIn
  end
       
  def test_speed=(aIn)
    @test_speed = aIn
  end
  
  def ips
    return @ips
  end
  
  def ipm
    return @ipm
  end
  
  
  def max_x_move
      @max_x_move
  end
   
  def max_x_move=(aNum)
      @max_x_move  = aNum
      @max_x = @max_x_move + @min_x
  end
  
  def min_x
     @min_x
  end
  
  def min_x=(aNum)
     @min_x       =  aNum
     @max_x = @max_x_move + @min_x
  end
  
  
  def max_x
     @max_x
  end
  
  def max_x=(aNum)     
     @max_x       = aNum
  end
  
  
  def  max_y
    @max_y 
  end
  
  def  max_y=(aNum)
    @max_y  = aNum
	#print "(CNCMachine.Max_y=", aNum, " max_y=", @max_y, ")\n"
  end
  
  
  def min_y
     @min_y
   end
  
  
  def min_y=(aNum)
     @min_y       = aNum
   end
  
    
  def max_z
    @max_z
  end
   
   
  def max_z=(aNum)
    @max_z = aNum
  end
  
  def min_z
    @min_z
  end 
  
  
  def min_z=(aNum)
    @min_z = aNum
  end 

    
  def min_a
    @min_a
  end 
  
  
  def min_a=(aNum)
    @min_a = aNum
  end 
  
     
  # lookup the IPS (inch per second rating specified.
  # find the one that is above it and below it
  # and use those to calculate the correct FSpeed
  # based and it's relative location between those
  # two IPS speeds.
  def get_fspeed_from_IPS(aIPS)
    #print "aIPS=", aIPS
    foi =0
    for tips in @ips
      #print "foi=", foi,  "  tips=", tips, "\n"
      if tips > aIPS
        if (foi == 0)
          return @fspeed[0]
        else
          ips_delta = (@ips[foi] - @ips[foi - 1])
          if (ips_delta == 0)
            return @fspeed[foi]
          end
          tdelta = aIPS - @ips[foi-1]
          ips_ratio = tdelta / ips_delta
          
          speed_delta = @fspeed[foi] - @fspeed[foi - 1]
          adjust_speed = @fspeed[foi] + speed_delta * ips_ratio
          return adjust_speed
        end # else
      end # found first one over.
      foi += 1
    end #for 
    # never found the first one over.
    return @fspeed[@fspeed.length - 1] # return the last item from he array
  end  # method

end #class

