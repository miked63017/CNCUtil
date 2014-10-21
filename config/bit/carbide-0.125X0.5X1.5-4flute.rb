# carbide 1/8 (0.125) diam bit.  4 flute
# flute length is 1/2 inche and the bit is
# 1.5 inches long total. 
# sales@procarbide.com #HP-50200
# 
# 
# measures 0.12 with digital caliper. 
#
self.product_num      = "HP-50200"
self.num_cut_tooth    = 4.0
self.rpm_adjust       = 1.0
self.bit_len          = 1.5
self.flute_len        = 0.5
self.diam             = 0.123 # 1/8 inch
self.per_tooth_adjust = 0.45  # multiply cut per tooth by 
                             # calc for the material by this
                             # amount.  Normal calculations 
                             # are for steel.   We found 
                             # this necessary because we 
                             # where getting a high number 
                             # of breaking bits when using 
                             # the   pure calculations.
                             
self.cut_depth_adjust = 0.45 # Multiply the cutting depth by
                             # this number because we where
                             # finding that some bits could
                             # not cust at the chart rate
                             # for the material.
self.sfm_adjust       = 1.0
self.bit_choked       = 0.5  # amount of bit inside collet.


self.max_mill_depth   = 1.5 # This is the maximum depth this 
                            # bit could reach staight 
                            # down into the material if 
                            # plunging directly into
                            # a hole  Bits with a shaft
                            # equal to or smaller than 
                            # flute size can mill deeper 
                            # than flute length.