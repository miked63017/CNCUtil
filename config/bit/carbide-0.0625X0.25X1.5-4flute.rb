# carbide 1/16 (0.0624) diam bit.  4 flute
# flute length is 1/4 inch and the bit is
# 1.5 inches long total.  Shaft is 1/8" 
# sales@procarbide.com #50000
# 
# 
#
self.product_num      = "50000"
self.num_cut_tooth    = 4.0
self.rpm_adjust       = 2.0
self.bit_len          = 1.5
self.flute_len        = 0.25
self.flute_smaller_than_shaft = true
self.diam             = 0.0625 # 1/16 inch
self.shaft_diam       = 0.0625
self.per_tooth_adjust = 0.4  # multiply cut per tooth by 
                             # calc for the material by this
                             # amount.  Normal calculations 
                             # are for steel.   We found 
                             # this necessary because we 
                             # where getting a high number 
                             # of breaking bits when using 
                             # the   pure calculations.
                             
self.cut_depth_adjust = 0.1  # Multiply the cutting depth by
                             # this number because we where
                             # finding that some bits could
                             # not cust at the chart rate
                             # for the material.
self.sfm_adjust       = 0.1
self.bit_choked       = 1.0  # amount of bit inside collet.


self.max_mill_depth   = 0.25 # This is the maximum depth this 
                            # bit could reach staight 
                            # down into the material if 
                            # plunging directly into
                            # a hole  Bits with a shaft
                            # equal to or smaller than 
                            # flute size can mill deeper 
                            # than flute length.