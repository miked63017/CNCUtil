# carbide 1/4 (0.250) diam bit.  6 flute
# flute length is 3/4 inche and the bit is
# 2.5 inches long total. 
# sales@procarbide.com #50592
#
self.product_num      = 50592
self.num_cut_tooth    = 6.0
self.rpm_adjust       = 1.0
self.bit_len          = 2.5
self.flute_len        = 0.75
self.diam             = 0.245 # 1/4 inch
self.per_tooth_adjust = 0.45 # multiply cut per tooth by 
                             # calc for the material by this
                             # amount.  Normal calculations 
                             # are for steel.   We found 
                             # this necessary because we 
                             # where getting a high number 
                             # of breaking bits when using 
                             # the   pure calculations.
                             
self.cut_depth_adjust = 1.0  # Multiply the cutting depth by
                             # this number because we where
                             # finding that some bits could
                             # not cust at the chart rate
                             # for the material.
self.sfm_adjust       = 1.0
self.bit_choked       = 1.0  # inches of bit installed 
                             # inside collet 


self.max_mill_depth   = 4.0 # This is the maximum depth this 
                            # bit could reach staight 
                            # down into the material if 
                            # plunging directly into
                            # a hole  Bits with a shaft
                            # equal to or smaller than 
                            # flute size can mill deeper 
                            # than flute length.