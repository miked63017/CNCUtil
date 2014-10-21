#cncGeometry_test.rb
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
###########################
###  MAIN TEST CODE
###########################

testing = true
if testing == true
  if false
    print "calc_distance(1,1,22,19) = ",calc_distance(1,1,22,19), "\n"
    print "calc_distance(1,1,1,1)     = ", calc_distance(1,1,1,1), "\n"
    dist_c1 = calc_distance(0,0,-23,-19)
    print "dist_c1 = calc_distance(0,0,-23,-19)=",  dist_c1
    print "\n\n\n"
    print "Q1 calc_angle(0,0,1,1) =",  calc_angle(0,0, 1,1),  "\n\n"

  end # testing distance



  if false
    print "verify angle calcs over 9 up 3 expect  18.4 degrees\n" 
    print "either above or below the axis.  In quadrant 1 the\n"
    print " point is 18.4 degrees above the 90 degree axis or\n"
    
    ca1 = calc_angle(0,0,9,3)
    cd1 = calc_distance(0,0,9,3)
    print "Q1 calc_angle(0,0, 9,3)=", ca1, "\n"
    pp = calc_point_from_angle(0.0,0.0, ca1, cd1)
    print "pp=", pp, "\n\n"


    ca2 = calc_angle(0,0,9,-3)
    cd2 = calc_distance(0,0,9,-3)
    print "Q2 calc_angle(0,0, 9,-3)=", ca2, "\n"
    pp = calc_point_from_angle(0.0,0.0, ca2, cd2)
    print "pp=", pp, "\n\n"

    ca3 = calc_angle(0,0,-9,-3)
    cd3 = calc_distance(0,0,-9,-3)
    print "Q3 angle_c1 = calc_angle(0,0, -9,-3)=", ca3, "\n"
    pp = calc_point_from_angle(0.0,0.0, ca3, cd3)
    print "pp=", pp, "\n\n"

    ca4 = calc_angle(0,0,-9,3)
    cd4 = calc_distance(0,0,-9,3)
    print "Q4  calc_angle(0,0, -9,3)=",ca4, "\n"
    pp = calc_point_from_angle(0.0,0.0, ca4, cd4)
    print "pp=", pp, "\n\n"


    angle_c1 =  calc_angle(0,0,-9,-3)
    angle_c2 =  calc_angle(0,0,-9,3)

   print "\n"
   print "\n"
  end #if true testing angles



  if (false)  # testing conversions to rectangular coordinates
    ### Practice convert rectangular to polar
    print "\n\nTest Polar conversion\n"

    p1 = conv_xy_to_polar(3,4)
    print "p1 x=3,y=4 as polar ",  p1.to_s, "\n"

    p2 = conv_xy_to_polar(3,-4)
    print "p2 x=3,y=-4 as polar ", p2.to_s, "\n"

    p3 = conv_xy_to_polar(-3,-4)
    print "p3 x=-3,y=-4 as polar ",p3.to_s, "\n"

    p4 = conv_xy_to_polar(-3,4)
    print "p4 x=-3,y=4 as polar ",p4.to_s, "\n"

    p5 = conv_xy_to_polar(8,6)
    print "p5 x=8,y=6 as polar ",conv_xy_to_polar(8,6),  "\n"

    # Now test convert back to rectangular
    ### Practice convert rectangular to polar
    print "\n\nTest Polar conversion\n"

    r1 = polar_to_xy_(p1)
    print "should be x=3, y=4\n"
    print "CONV", p1.to_s,  "\n", r1.to_s,"\n\n"


    r2 = polar_to_xy_(p2)
    print "should be x=3, y=-4\n"
    print "CONV", p2.to_s,  "\n", r2.to_s,"\n\n"

    r3 = polar_to_xy_(p3)
    print "should be x=-3, y=-4\n"
    print "CONV", p3.to_s,  "\n", r3.to_s,"\n\n"

    r4 = polar_to_xy_(p4)
    print "should be x=-3, y=4\n"
    print "CONV", p4.to_s,  "\n", r4.to_s,"\n\n"

    r5 = polar_to_xy_(p5)
    print "should be x=3, y=4\n"
    print "CONV", p5.to_s,  "\n", r5.to_s,"\n\n"


  end #if testing polar


  if false # testing basic walk around the circle
    print "\n\n"
    # test ability to walk around a circle and
    # rotate a point by 30 degrees all the way
    # around the circle.   We would use this
    # to calculate points in a arch but also to
    # calculate points in a circular array
    start_angle = 10
    curr_angle = start_angle
    pp = calc_point_from_angle(0.0,0.0,curr_angle,6)
    p2 = pp
    cc = 0
    no_steps = 15
    angle_inc = 360.0 / no_steps
    print "p2=", p2, "\n\n\n"
    #p2 = calc_point_rotated_relative(p2.x, p2.y,1)
    print "angle_inc = ", angle_inc, "\n"
    print "pp = ", pp, "\n"
    #print "p2 rotated 1 degree =", p2, "\n"


    print "   relative rotate point = ", p2, "\n"
    while (cc < no_steps)
       curr_angle  += angle_inc
       pp = calc_point_from_angle(0,0,curr_angle,6)
       print "\ncc=", cc, "  curr_angle=", curr_angle, " pp = ", pp, "\n"
       p2 = calc_point_rotated_relative(p2.x, p2.y, angle_inc)
       print "   relative rotate point = ", p2, "\n"
       cc += 1  
    end


  end # if walk around circle

end # if testing