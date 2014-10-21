# carbide 1/4 (0.250) diam bit. 2 flute double ended 
#  
#actually
# seems to be .248 becuase holes it 
# drills can not accept a full 
# .250 rod. 
# 
# flute length is 0.5 inche and the bit is
# 2.0 inches long total of which a maximum
# of about 1.5 inches is usable.
# verry smooth cut better than some 6 flute
# bits I have tried
# sales@procarbide.com #58401
#
self.product_num      = 58401
self.num_cut_tooth    = 2.0
self.rpm_adjust       = 1.0
self.bit_len          = 2.5
self.flute_len        = 0.75
self.diam             = 0.245 # 1/4 inch
self.per_tooth_adjust = 1.4  # 0.55 # multiply cut per tooth by 
                             # calc for the material by this
                             # amount.  Normal calculations 
                             # are for steel.   We found 
                             # this necessary because we 
                             # where getting a high number 
                             # of breaking bits when using 
                             # the   pure calculations.
                             
self.cut_depth_adjust = 1.0 #0.75  # Multiply the cutting depth by
                             # this number because we where
                             # finding that some bits could
                             # not cust at the chart rate
                             # for the material.
self.sfm_adjust       = 1.0
self.bit_choked       = 1.0  # inches of bit installed 
                             # inside collet 


self.max_mill_depth   = 1.0 # This is the maximum depth this 
                            # bit could reach staight 
                            # down into the material if 
                            # plunging directly into
                            # a hole  Bits with a shaft
                            # equal to or smaller than 
                            # flute size can mill deeper 
                            # than flute length.