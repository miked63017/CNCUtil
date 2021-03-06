# cncBit.rb
#
# The loaded config files specifiy an array of 
#  off RPM,  load per tooth and recomended maximum
#  cut depth for each material.  These can be used by
#  the local bit to calculate maximum depth and feed
#  rates for a given bit.
#
#  normal consensus is to always feed a shallow depth
#  and move at a faster speed rather than take deep
#  cuts.  this changes however when doing finsh cuts
#  on sidewalls where we want to take the maximum 
#  cut depth allowed by the flute while reducing the
#  amount of cut being taken into the sidewall and
#  reducing speed.
#
# In generally we always equate everything to feed per tooth
# which we can adjust for varying conditions.   We get our
# maximum rpm for a given bit size from the material however
# our local bit can adjust that setting such as carbide 
# which is allowed to take a larger bite per tooth and run 
# to run at a twice speed as equivelant steel bit. 
# 100% higher RPM than high speed steel.
#
#
# SFM = surface feet per min = RPM * cutter_diam * 0.262
#    Surface feed per minute it equates to chip load 
#    What is the 0.262 constant?  
#    We normally don't use surface foot per minute instead
#    use use a cut per tooth to dervive a Inch per second
#    feed rate.  These could be used to calculate a SFM 
#    if needed. 
#
# Chip Load = Feed Rate (in / min) / 
#     (RPM * number of cutting teeth)
#    Chiploads are generally set from 0.002 to 0.005 however
#    aluminum can tolerate 0.15 when taking shallow cuts.
#
# feed per tooth is the bite of material each tooth 
# takes as it comes around.  For example if a
# two flute bit is spinning at 1,000 RPM then is 
# is taking 2000
# cuts per minut or 2000 / 60 = 33 cuts per second so
# if we want it to take 0.01 inchs per cut we would 
# have to move it at a rate of 33 * 0.01 = .33 inches
#  per second or 19.8 inches per minute.
#
# If the cut depth is increased then we have to decrease the feed rate
# by a proportional amount.   This will only matter if we need to finish 
# cut a sidewall so that we don't see all the layered cuts.
#
# this calculation is based on the a full width cut.  when we take
# a fractional cut we can increase the speed proportionally .
#
# ips (inch_per_second)  =  (rpm * 60) * number_of_teeth) * per_tooth_load
#                           ((1000 * 60)* 2) * 0.01) = 0.33
# 
# ips has to be adjusted for current cut depth 
#
#     ips = ips * (recomended_cut_depth / (cur_cut_depth / recomended_cut_depth))
#        so for a cut depth of 1" when the recomended cut
#        depth is 0.10  would solve as
#    ips = old_ips (0.33) * (0.1 / (1.0 / 0.1) = 0.01
#
#   ips also has to be adjusted for the cuting swath so
#   so for a cutting swath that is only 1/4" the full swath
#   ips would be increased by 50%.  Only 50% of the bit cuts
#   anyway to we have to deduct the other 50%
#
#
#  Each Material  such as aluminum-100x.rb includes 
#  a variable called per_tooth which is loaded as
#  an array of bit diameters that at the maximum cut 
#  per tooth for bit's of that diameter. 
#  We find the first bit diameter that is bigger 
#  than the existing bit and then take next smaller 
#  bit and calculate a number in between so if the
#  bit we are using is 75% of the difference between 
#  the 0.125 bit and the .250 bit we would calculate 
#  our cut per tooth as 75% of the way along the 
#  difference between the two bit sizes.   material 
#  file includes diams[] and  rpms[] and cut_depth[]. 
#  These are all positionally identical so the diam[] 
#  array is 0..N will match positionally with 
#  the rpm[] and  per_tooth[] to allow the cut per 
#  tooth to  be easily looked up by the material 
#  type currently selected.    All these values are
#  reset by the bit when new bits are selected or when
#  a new materials are selected.   Even the cut depth
#  increment is set based on the bit and material selected.
#    
    
  
  
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

require 'DynamicLoader'
require 'CNCMaterial'

  ##########################################
  class CNCBit
  ##########################################
    include  DynamicLoader
    extend  DynamicLoader
     
    attr_accessor :mill, :flute_len, :diam, :cut_inc_max, :cut_depth_inc_max, :rpm_adjust, :product_num, :per_tooth_adjust, :cut_depth_adjust, :sfm_adjust, :bit_choked, :num_cut_tooth, :flute_smaller_than_shaft
   
   
    
    #   #   #   #   #   #   #   #   #   #   #   #
    # default initializer sets the following instance
    # variables.   Bits are normally loaded with 
    # parameters automatically by reading in and
    # evaluating a config file.  By convention these
    # config files are stored in the config/bit 
    # sub directory.
    # * @diam
    # * @length
    # * @flute_len
    # * @cut_depth
    #
    #  The config file name is read and evaluated
    #  to insert values specific for this bit.
    #  such as hardness, lenght, diameter, etc.
    #  The config file is composed of a series
    #  of single line ruby statements that subject
    #  to some limitation can call any setter / getter
    #  for valid for this object.
    #
    #  Bits are normally loaded automatically by
    #  the main machine config process however they
    #  can be loaded into bit # slots of 1 to 30
    #  with explicit calls.
    #
    #
    #  TODO:  Actually read and process the config
    #   file
    #   #   #   #   #   #   #   #   #   #   #   #
    def initialize(mill, config_file_name = "config/bit/carbide-0.250X0.75X2.5-6flute.rb")
    #   #   #   #   #   #   #   #   #   #   #   #
      @mill        = mill
      
        # Returns Diameter of the cutting diameter for this
        # bit.  If the bit was plunged into the material 
        # and made a single cut line.  That line would be
        # exactly diam (this number) wide.
      self.diam        = 0.375
      @length      = 0.5
      
        #  Returns Total length of the cutting area
        #  of the bit. This is the maximum
        #  amount the bit could ever cut 
        #  in a single swath.  The actual
        #  amount cut in a single swath is
        #  obtained from cut_depth_inc_curr
        #  which adds in calculations such as
        #  bit and material composition.
        #
        # * Maximum Cutting Area of bit
        #
      @flute_len   = 0.2
      
      @num_cut_tooth=2
      @max_mill_depth=nil
      @product_num   = nil
      
      
      @cut_inc_max = @diam * 0.25
      @cut_inc     = @cut_inc_max
      @cut_depth   = @flute_len
      @cut_depth_inc = @cut_inc
      @cut_depth_inc_max = @cut_depth
      
      @rpm_adjust  = 1.0
      @per_tooth_adjust = 1.0
      @cut_depth_adjust = 1.0
      @sfm_adjust = 1.0
      
      @speed_curr  = 15.0
      @speed_fast  = 15.0
      @speed_plung = 5.0
      @speed_normal= 12.0
      @speed_max   = 20.0
      @speed_finish   = 10.0
      
      @adj_type = "aluminum6010"

      @bit_choked = 0.5
      @plung_speed = 0.5
      @flute_smaller_than_shaft = false

      if (config_file_name != nil)
        #read
        # the acutal config file and
        # interpolate it into local 
        # variables.
        load_file(config_file_name)
      end # if
      
      #print "\nbit initialize @diam=", @diam, ")\n"
      
      
      #@aluminum_rpm = 3500
      #if (@diam < (3/16))
      #  @aluminum_max_face_cut = @diam / 8
      #else 
      #  @aluminum_max_face_cut = @diam / 4
      #end
    end # init 

    
    #   #   #   #   #   #   #   #   #   #   #   #
    # recalculate current paramaters based on 
    # material and machine.
    #   #   #   #   #   #   #   #   #   #   #   #
    def recalc()
    #   #   #   #   #   #   #   #   #   #   #   #
      @cut_depth_inc = @mill.material.get_cut_depth_inc(@diam) * cut_depth_adjust
      @cut_depth_inc_max = @cut_depth_inc
      @cut_depth = self.bit_len - self.bit_choked
      #@cut_inc_max = @diam / 8.0
      #@cut_inc     = @cut_inc_max
      #@cut_depth   = @flute_len
      #@cut_depth_inc = @cut_depth_inc
      #@cut_depth_inc_max = @cut_depth
        
      @speed_curr  = get_fspeed()
      @speed_fast  = @speed_curr 
      @speed_plung = @speed_curr / 9.0
      @speed_normal= @speed_curr
      @speed_max   = @speed_curr
      @speed_finish= @speed_curr / 2.5
      
 
      
    end  # meth

    #   #   #   #   #   #   #   #   #   #   #   #
    def adjust_speeds_by_material_type(aType=nil)
    #   #   #   #   #   #   #   #   #   #   #   #         
     # TODO: Adjustments like this
     #   should be made a the bit / matieral
     #   level based on the material hardness.
     
     if (aType == nil)
       aType = @adj_type
     else
       @adj_type = aType
     end
       
     print "(adjust speeds for material ", aType, ")\n"
     # Defaults assume a hard aluminum
     # like  6010 or Fortel
       
     mult_speed   = 1.0
     mult_cut_inc = 1.0
     mult_cut_depth_inc = 1.0
     mult_plung_speed = 1.0
                 
     if aType == "uhmw"
       # I can go much faster if plastic and can cut
       # deeper.
       mult_speed   = 1.8
       mult_cut_inc = 1.5
       mult_cut_depth_inc = 2.3
       mult_plung_speed = 2.0
    elsif aType == "aluminum"
       mult_speed   = 1.0
       mult_cut_inc = 1
       mult_cut_depth_inc = 1.0 
       mult_plung_speed = 0.5
   elsif aType == "steel"
       mult_speed   = 0.43
       mult_cut_inc = 0.65
       mult_cut_depth_inc = 0.65
       mult_plung_speed = 0.020
    elsif aType == "acrylic"
       # I can go much faster if plastic and can cut
       # deeper.
       mult_speed   = 2.35
       mult_cut_inc = 1.0
       mult_cut_depth_inc = 3.0   
       mult_plung_speed = 3.0
       
       #mult_speed   = 1.35
       #mult_cut_inc = 1.0
       #mult_cut_depth_inc = 2.0    
       #mult_plung_speed = 3.0

     elsif aType == "foam"
       mult_speed   = 4.0
       mult_cut_inc = 3.0
       mult_cut_depth_inc = 35 
       mult_plung_speed = 45  
     elsif aType == "wood"
       mult_speed   = 3.0
       mult_cut_inc = 2.0
       mult_cut_depth_inc = 3.0
       mult_plung_speed = 2.0
    elsif aType == "particle_board"
       mult_speed   = 4.5
       mult_cut_inc = 1.5
       mult_cut_depth_inc = 20.0
       mult_plung_speed = 7.0	   
     elsif aType == "balsa"
       mult_speed   = 5.5
       mult_cut_inc = 16.0
       mult_cut_depth_inc = 5.5
       mult_plung_speed = 17.0
     end #if
     
     print "(mult_speed = ", mult_speed, ")\n"
     print "(mult_cut_inc = ", mult_cut_inc, ")\n"
     print "(mult_cut_depth_inc=", mult_cut_depth_inc, ")\n"
     print "(mult_plungg_speed=", mult_plung_speed, ")\n"
     
     
     
     set_speed(speed * mult_speed)
     mill.set_cut_inc(cut_inc * mult_cut_inc)    
     set_plung_speed(plung_speed * mult_plung_speed)
     
     
     if (mult_speed != 1.0)
       print "(new speed =", mill.speed, ")\n"
     end
     
     if (mult_cut_inc != 1.0)
       print "(new cut_inc = ", mill.cut_inc, ")\n"
     end
     
     if (mult_cut_depth_inc != 1.0)   
       print "(original cut_depth_inc=", mill.cut_depth_inc, " )\n"           
       mill.set_cut_depth_inc(cut_depth_inc * mult_cut_depth_inc)
       print "(new cut_depth_inc=", mill.cut_depth_inc, ")\n"
     end
     
     if (mult_plung_speed != 1.0)     
       print "(new plung_speed=",  plung_speed, ")\n"
     end
     
     
     
     
     
    end # method
    
    
    
  


    #  total length of the bit.  This is used
    #  to determine how deep this bit can
    #  plung total before the collet or holder
    #  would impact with the work surface.
    #
    #  * Total length of bit protruding from Collet which
    #    has a diameter equal to or less than flute cutting
    #    diameter.
    #
    def bit_len
      return @length
    end #meth
       #
       
    def bit_len=(aNum)
      @length = aNum
    end #meth

    
    # This is the maximum depth this bit could reach staight 
    # down into the material if plunging directly into
    # a hole
    def  max_mill_depth
      if (@max_mill_depth == nil)
        return flute_len
      else
       return @max_mill_depth
      end #if
    end #meth
    
    def max_mill_depth=(aDepth)
      @max_mill_depth = aDepth
    end #meth
    
    
    

 


  

    # Returns shaft Diameter diameter for this 
    #  bit.  On smaller bits this is commonly
    #  larger than the cutting diameter.
    #  on larger bits this is commonly smaller
    #  than the cutting diameter.
    def shaft_diam
       if (@shaft_diam == nil)
         return @diam
       else
         return @shaft_diam
       end #if
    end #meth
    
    #
    def shaft_diam=(aDiameter)
       @shaft_diam = aDiameter
    end #meth

    
    # Returns a number which is 1/2 the cutting diameter
    # of this bit.
    def radius
       @diam / 2.0  
    end #meth
     
    # Returns a number which is 1/2 the cutting diameter
    # of this bit.
    def diam
       @diam   
    end #meth
     
    # Returns a number which is 1/2 the cutting diameter
    # of this bit.
    def diam=(aDiameter)
	#print "(set diameter=", aDiameter, ")\n"
       @diam  = aDiameter
    end #meth
     
    

    # The amount the bit can be safely 
    # advanced into the material for
    # a single side cut when making rough
    # cuts especially for pocketing.  This
    # number is combined with the 
    # cut_depth_increment and is derived
    # predominantly from a combination of
    # flute length,  bit composition
    # and material hardness.
    #
    # TODO: enhance this so that it
    # is using bit and material
    #
    def set_cut_increment_rough=(aDepth)
	  if (aDepth == nil)
        @cut_inc = @cut_inc_max
	  else
	    @cut_inc = aDepth
	  end
      return @cut_inc
    end #meth
	

    #  Same as cut_increment_rough
    #  but generally a smaller number
    #  because it is easier to get high
    #  quality finish cuts when removing
    #  less material.
    #  TODO: enhance this so that it
    #   is using bit and material
    #
    #########################
    def set_cut_increment_finish
    #########################
      @cut_inc = @cut_inc_max *  0.35
      return @cut_inc
    end #meth 

    #########################
    def cut_inc
    #########################
      return @cut_inc
    end #meth
        
    #########################
    def cut_increment_rough
    #########################
      @cut_inc_max
    end # meth
    
    #########################
    def cut_increment_finish
    #########################
      @cut_inc_max *  0.35
    end # meth
    
    #########################
    def cut_inc=(aCutInc)
    #########################    
      if (aCutInc > @cut_inc_max)
        @cut_inc = @cut_inc_max
      else
        @cut_inc = aCutInc
      end
      @cut_inc
    end
    
    
   
    #  The maximum depth of a safe cut
    #  when milling a full bit diameter
    #  swath through the work material
    #  when rough cutting.
    #
    #  This is generally faster for
    #  rough cuts and lower for finish
    #  cuts and is faster for soft 
    #  materials like Strofoam than it
    #  is for harder materials.
    # 
    #  TODO: enhance this so that it
    #   is using bit and material
    #
    def cut_depth_rough
      @cut_depth_inc = @cut_depth_inc_max
      @cut_depth_inc
    end #meth 

    #  Same as cut_depth_rough but is
    #  generally a smaller number because
    #  it is easier to get a high quality
    #  finish when removing less material.
    #
    #  TODO: enhance this so that it
    #   is using bit and material
    # - - - - - - - - - - - - - - - -
    def cut_depth_finish
       @cut_depth_inc = @cut_depth_inc_max * 0.2
       @cut_depth_inc
    end #meth 

   #   #   #   #   #   #   #   #   #   #   #   #    
   #  Returns the current cutting 
   #  depth increment.  This is based
   #  on the current material, type 
   #  of bit,  size of mill and 
   #  whether finish cutting or rough
   #  cutting.   The mill will make this
   #  number have to make a number of
   #  passes to make deeper cuts and the
   #  total number is generally calculated
   #  by dividing total depth of cut by
   #  this number.   The method 
   #  set_speed_finish will generally cause
   #  this method to returrn a smaller number
   #  than when set_speed_rough is used.
   #
   #  * TODO: enhance this so that it
   #  * is using bit and material
   #  * knowledge to determine proper
   #  * cut depth.
   #   #   #   #   #   #   #   #   #   #   #   #
   def cut_depth_inc_curr
   #   #   #   #   #   #   #   #   #   #   #   #
     return cut_depth_inc()
   end #meth 

   
   # retreive cut_depth_incre
   def cut_depth_inc
     return @cut_depth_inc
   end #meth 

   # Set the cutting depth increment
   def cut_depth_inc=(aDepthInc)
     ####if aDepthInc > @cut_depth_inc_max
     ####  aDepthInc = cut_depth_inc_max
     ####end #if
     @cut_depth_inc = aDepthInc
   end #meth 
   
   
   
  
 
   
   # for a given diameter of bit operating at
   # a given RPM calculate inch per second feed.
   #   #   #   #   #   #   #   #   #   #   #   #
   def get_inch_per_sec(aMaterial, aRPM=nil,  cut_swath=nil, cut_depth=nil)
   #   #   #   #   #   #   #   #   #   #   #   #
       if (aRPM == nil)
         aRPM = aMaterial.get_rpm(@diam )
       end
       cpt = aMaterial.get_cut_per_tooth(@diam)
       ips = (aRPM / 60) * @num_cut_tooth * cpt * per_tooth_adjust
       # adjust for cutt swath
       # adjust for cut_depth
       # adjust for finish versus rough
       return ips  
     end
  
   #   #   #   #   #   #   #   #   #   #   #   #
   def get_fspeed()
   #   #   #   #   #   #   #   #   #   #   #   #
      ips = get_inch_per_sec(@mill.material)
      fspeed = @mill.machine.get_fspeed_from_IPS(ips)  
      @speed_max = fspeed    
      return fspeed
   end
   
   #   #   #   #   #   #   #   #   #   #   #   #
   def speed
   #   #   #   #   #   #   #   #   #   #   #   #
     #print "(bit.speed = ", @speed_curr,")\n"
     return @speed_curr 
   end # meth
    

   #   #   #   #   #   #   #   #   #   #   #   #
   def set_speed(aSpeed)
   #   #   #   #   #   #   #   #   #   #   #   #
       #print "(set_speed ", aSpeed, ")\n"
       #if ((aSpeed > 0) && (aSpeed <= @speed_max))
         @speed_curr = aSpeed
       #end #if
   end # meth


   #   #   #   #   #   #   #   #   #   #   #   #
   def set_speed_rough
   #   #   #   #   #   #   #   #   #   #   #   #
     #print "(set_speed_rough )\n"
     set_speed(@speed_max)
   end # meth

   #   #   #   #   #   #   #   #   #   #   #   #
   def set_speed_finish
   #   #   #   #   #   #   #   #   #   #   #   #
     #print "(set_speed_finish )\n"
     set_speed(@speed_finish)
   end # meth

   
   
   
   
   def plung_speed
     return @speed_plung
   end #meth
   
   #########################
    def plung_speed=(aSpeed)
    #########################    
       set_plung_speed(aSpeed)
   end #meth
   
    def set_plung_speed(aSpeed)
     @speed_plung= aSpeed
     return self
   end #meth
   
   
   

   
  end #class 


