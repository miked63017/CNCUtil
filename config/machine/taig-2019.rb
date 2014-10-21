    # Configuration file for the taig-2019 vertical mill.
    #  read by cncMachine.   This file determines the
    #  X,Y,Z limits and relative movement speeds at various
    #  F speeds based on empiracle tests.
    #  These are used latter in the process to determine
    #  which F speed to use to obtain a desired IPS inch
    #  per second feed rate and the IPS is derived from 
    #  the cut per tooth for various materials and bit
    #  sizes.
    
     self.max_x_move  = 14
     self.min_x       = -13.65
     self.max_x       =  13.65
     self.max_y       = 5.35 #3.90 when material is thicker than 1 inch it impacts the back column
     self.min_y       = -0.25
     self.max_z       = 4.0
     self.min_z       = -4.0
    
      self.spindle_rpm = [10839, 6513, 4365, 2340, 1975, 1200]
       # RPM of spindel in Taig 2019 with belt positions starting
       # at the bottom as the fastest and 
       # top as slowest and working towards the bottom.  This mill  seems to have a problem reaching full speed in the highest
       # position while all others seem to work OK.  These numbers are used
       # to calculate what belt postion to request based on the work material
       # and bit being used

       
       self.test_speed_fract = [609, 302, 202, 152,  123, 100, 85, 75,68, 60] 
       # speeds at 0.1 through 1.0 needed for very slow
       # operations.   Postion one in this instance is
       # showing that it took 609 seconds to move 1 inch
       # at 0.1F and 202 seconds to move the same inche
       # at 0.3F.
       
       
      self.test_speed = [60,44,30,21,19,15,12,11,9,8,7.5,7,6.5,6.4,6.2,5.5,5.4,5.3,4.0,3.1]
       # empiracle test of speed of mill to move
       # the X,Y axis one inch
       # at the same time.  Starting in F1 
       # working up through F20 results are in 
       # number of seconds required for the move. 
       # This value is used to create a speed of 
       # feet per minute for the various feed speeds