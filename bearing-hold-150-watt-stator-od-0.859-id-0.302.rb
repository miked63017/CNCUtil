#  Mill bearing holder for smaller wind turbine.  This involes 4 1/4"
# holes for bolts with a 3/4" indent for the bearing centered over
# a 5/8" hole to allow the axel to pass through. 


require 'CNCMill'
require 'CNCShapeCircle'

material_x_len = 5.0
material_y_len = 5.0
mat_thick =  0.190
cent_x = 0
cent_y = material_y_len / 2.0

bearing_thick =    0.267
bearing_od_diam = 0.859
bearing_id_diam = 0.302 
mount_diam = 0.25 + 0.03 # Make a little larger to give positioning room
mount_offset = 2.0

max_bearing_sock_ratio = 0.45
max_bearing_sock_depth = mat_thick * max_bearing_sock_ratio

if bearing_thick > max_bearing_sock_depth
	# Make sure we leave enough material
	# to support our bearing
	bearing_thick = max_bearing_sock_depth	
end


bearing_depth = 0 - bearing_thick
drill_through_depth = 0 - mat_thick
bearing_pass_diam = (bearing_od_diam + bearing_id_diam + bearing_id_diam) / 3.0

aMill = CNCMill.new
aMill.job_start()
aMill.load_bit("config/bit/carbide-0.250X0.55X1.5-2flute.rb", "Load 1/4 inch 2 flute bit", 0.5, "acrylic")    
aMill.home
#aMill.cut_depth_inc = aMill.cut_depth_inc * 2.0

aCircle = CNCShapeCircle.new(aMill, cent_x, cent_y)
aCircle.beg_depth = 0


# Mill the bearing pocket
aCircle.mill_pocket(cent_x, cent_y, bearing_od_diam,  bearing_depth)
# Mill the axel pass through hole
aCircle.beg_depth = bearing_depth
aCircle.mill_pocket(cent_x, cent_y, bearing_pass_diam, drill_through_depth)
aCircle.beg_depth = 0

# Mill the mounting bolt holes
aCircle.mill_pocket(cent_x - mount_offset, cent_y ,  mount_diam, drill_through_depth)
aMill.retract()
aCircle.mill_pocket(cent_x  + mount_offset, cent_y ,  mount_diam, drill_through_depth)
aMill.retract()
aCircle.mill_pocket(cent_x  , cent_y + mount_offset,  mount_diam, drill_through_depth)
aMill.retract()
aCircle.mill_pocket(cent_x  , cent_y -  mount_offset,  mount_diam, drill_through_depth)
aMill.retract()

# Trace circles on mounting holes
# cut 90% of way through outside diam
cut_out_diam = (mount_offset * 2) + (mount_diam * 4)
cut_out_radius = cut_out_diam / 2.0
start_y = cent_y - cut_out_radius


aMill.move(cent_x, start_y)
mill_circle(aMill, cent_x,cent_y, cut_out_diam, beg_depth=0, depth=drill_through_depth * 0.95, adjust_for_bit_radius=true)

aMill.retract()
aMill.home()

aMill.job_finish()