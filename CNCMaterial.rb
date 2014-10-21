# cncMaterial.rb
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
require 'CNCBit'
require 'DynamicLoader'
require 'CNCMill'



  # *****************************************
  class CNCMaterial
  # *****************************************
    include  DynamicLoader
    extend  DynamicLoader
   

     # - - - - - - - - - - - - - - - -
     def initialize(aMill, load_fi_name="config/material/aluminum-100x.rb")
     # - - - - - - - - - - - - - - - -   
       @mill  = aMill
       @width = 4
       @length= 4
       @height= 4
       @max_speed = 15
       
       @diams = []
       @rpms  = []
       @per_tooth=[]
       @cut_depth=[]
           # these two arrays are used to calculate a recomended
           # maximum RPM at a given bit size for this material.
           # assuming high speed steel.  You can generally double
           # the RPM speed for carbid and take a slightly higher
           # per tooth rating.
   
      @brinell         =  nil
      @sfm_rough       =  nil
      @sfm_finish      =  nil
      @sfm_depth       =  nil

       
       load_file(load_fi_name)       
     end  #init
     
     def width
       @width
     end
     
     def length
       @length
     end
     
     def height
       @height
     end
     
     def max_speed
       @max_speed
     end
     
     def diams
       @diams
     end
     
     def rpms
       @rpms
     end
     
     
     def per_tooth
       @per_tooth
     end
     
     
     def cut_depth
       @cut_depth
     end
     
     def brinell
       @brinell
     end
     
     def sfm_rough
       @sfm_rough
     end
     
     
     def sfm_finish
       @sfm_finish
     end
     
     def sfm_depth
       @sfm_depth
     end
     
     
     
     
     
     def width=(aNum)
       @width = aNum
     end
     
     def length=(aNum)
       @length=aNum
     end
     
     def height=(aNum)
       @height=aNum
     end
     
     def max_speed=(aNum)
       @max_speed=aNum
     end
     
     def diams=(aIn)
       @diams=aIn
     end
     
     def rpms=(aIn)
       @rpms=aIn
     end
     
     
     def per_tooth=(aIn)
       @per_tooth=aIn
     end
     
     
     def cut_depth=(aIn)
       @cut_depth=aIn
     end
     
     def brinell=(aNum)
       @brinell = aNum
     end
     
     def sfm_rough=(aNum)
       @sfm_rough=aNum
     end
     
     
     def sfm_finish=(aNum)
       @sfm_finish=aNum
     end
     
     
     
     def sfm_depth=(aNum)
       @sfm_depth=aNum
     end
     
     
     #  for a given diamater of bit find  bit closest
     #  to the specified size and return that as an
     #  element number.
     def get_closest_bit_no(aDiam)
       min_dif = 99999999999
       keeper  = nil
       cc = 0
       for tDiam in @diams
         tdif = aDiam - tDiam
         tdif = tdif.abs()
         if tdif < min_dif
           min_dif = tdif
           keeper = cc
         end
         if (tDiam > aDiam)
           return keeper
           # since we know that the array is ordered
           # in increasing sizes if we hit one larger
           # than the bit we know that it will be closer
           # than any subsequent elements.
         end #if  
         cc += 1
       end #for
       return @diams.length - 1
     end #meth
     
     # for a given diameter of bit look up recomended bit RPM.
     def get_rpm(aDiam)
        bit_no = get_closest_bit_no(aDiam)
        rpm  = @rpms[bit_no]   
        return rpm     
     end
     
     # for a given diameter of bit lookup recomended
     # feed per tooth
     def get_cut_per_tooth(aDiam)
       bit_no = get_closest_bit_no(aDiam)
       cpm =  @per_tooth[bit_no]
       return cpm
     end

     def get_cut_depth_inc(aDiam)
       bit_no = get_closest_bit_no(aDiam)
       cdi = cut_depth[bit_no]
       return cdi
     end #meth
     
     # for a given diameter of bit operating at
     # a given RPM calculate inch per second feed.
     def get_inch_per_sec(aBit, aRPM=nil)
       return aBit.get_inch_per_sec(self, aRPM)
     end
     
     # for a given inch per second calcualtion 
     # calcualte a given inch per second feed
     # rate.   
     def get_fspeed_from_IPS(aIPS)
        return aMachine.get_F_speed_from_IPS(aIPS)
     end
     
     
          
     
  end #class
