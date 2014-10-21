#  Mill bearing holder for smaller wind turbine.  This involes 4 1/4"
# holes for bolts with a 3/4" indent for the bearing centered over
# a 5/8" hole to allow the axel to pass through. 


require 'CNCMill'
require 'CNCShapeCircle'


cent_x = 0.0
cent_y = 0.6
mat_thick = 0.225
bearing_thick = 0.1
bearing_od_diam = 0.75
bearing_id_diam = 0.50
mount_diam = 0.25 + 0.05 # Make a little larger to give positioning room
bearing_depth = 0 - bearing_thick
drill_through_depth = 0 - mat_thick
bearing_pass_diam = (bearing_od_diam + bearing_id_diam + bearing_id_diam) / 3.0

aMill = CNCMill.new
aMill.job_start()
aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "acrylic")    
aMill.home
#aMill.cut_depth_inc = aMill.cut_depth_inc * 2.0

aCircle = CNCShapeCircle.new(aMill, 1.5,1.5)
aCircle.beg_depth = 0


# Mill the bearing pocket
aCircle.mill_pocket(cent_x, cent_y, bearing_od_diam,  bearing_depth)
# Mill the axel pass through hole
aCircle.beg_depth = bearing_depth
aCircle.mill_pocket(cent_x, cent_y, bearing_pass_diam, drill_through_depth)
aCircle.beg_depth = 0

# Mill the mounting bolt holes
aCircle.mill_pocket(cent_x - 2.40, cent_y + 0.25,  mount_diam, drill_through_depth)
aMill.retract()
aCircle.mill_pocket(cent_x - 1.15, cent_y + 0.25,  mount_diam, drill_through_depth)
aMill.retract()
aCircle.mill_pocket(cent_x - 0.869, cent_y + 0.25,  mount_diam, drill_through_depth)
aMill.retract()

aCircle.mill_pocket(cent_x + 1.15, cent_y + 0.25,  mount_diam, drill_through_depth)
aMill.retract()
aCircle.mill_pocket(cent_x + 2.60, cent_y + 0.25,  mount_diam, drill_through_depth)


aMill.home()

aMill.job_finish()