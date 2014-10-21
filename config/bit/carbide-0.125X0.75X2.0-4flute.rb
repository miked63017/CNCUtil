# carbide 1/8 (0.125) diam bit.  4 flute
# flute length is 3/4 inche and the bit is
# 2 inches long total. 
# sales@procarbide.com #54090
#
self.product_num      = "54090"
self.num_cut_tooth    = 4.0
self.rpm_adjust       = 1.0
self.bit_len          = 1.5
self.flute_len        = 0.75
self.diam             = 0.123 # 1/8 inch
self.per_tooth_adjust = 0.2  # multiply cut per tooth by 
                             # calc for the material by this
                             # amount.  Normal calculations 
                             # are for steel.   We found 
                             # this necessary because we 
                             # where getting a high number 
                             # of breaking bits when using 
                             # the   pure calculations.
                             
self.cut_depth_adjust = 0.2  # Multiply the cutting depth by
                             # this number because we where
                             # finding that some bits could
                             # not cust at the chart rate
                             # for the material.
self.sfm_adjust       = 1.0
self.bit_choked       = 0.5  # amount of bit inside collet.


self.max_mill_depth   = 1.0 # This is the maximum depth this 
                            # bit could reach staight 
                            # down into the material if 
                            # plunging directly into
                            # a hole  Bits with a shaft
                            # equal to or smaller than 
                            # flute size can mill deeper 
                            # than flute length.