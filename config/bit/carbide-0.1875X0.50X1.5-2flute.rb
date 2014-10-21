# carbide 3/16 (0.1875) diam bit.  2 flute
# flute length is 0.5inche and the bit is
# 1.5 inches long total. 
# sales@procarbide.com #50303
#
self.product_num      = 50303
self.num_cut_tooth    = 2.0
self.rpm_adjust       = 1.0
self.bit_len          = 1.5
self.flute_len        = 0.50
self.diam             = 0.1869 # 3/16
self.per_tooth_adjust = 0.65 # multiply cut per tooth by 
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


self.max_mill_depth   = 1.5 # This is the maximum depth this 
                            # bit could reach staight 
                            # down into the material if 
                            # plunging directly into
                            # a hole  Bits with a shaft
                            # equal to or smaller than 
                            # flute size can mill deeper 
                            # than flute length.