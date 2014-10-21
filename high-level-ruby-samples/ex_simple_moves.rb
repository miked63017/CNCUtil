   # ex_simple_moves.rb
   # example showing simple moves of the milling head.
#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.
   
   require 'cncMill'
   aMill = CNCMill.new
   aMill.job_start()
   aMill.move(7,2,-0.2) 
      #       X,Y, Z
      # moves the mill from current location
      # to X of 7, Y of 2 and Z of -0.2
      # similar to G02 X7 Y2 Z-0.2 F5
      # however CNC Util will apply limits
      # so if you ask for a move outside 
      # the capability of your mill it will
      # move change the request to stop before
      # the mill would hit it's limit's.
   aMill.move(0,0)
      # Moves the head to the home position.
      # showing the the Z and A axis are 
      # optional.

   aMill.home()
      # retracts the milling head and
      # and then moves it home.  This
      # prevents accidental milling 
      # through your work piece when 
      # moving home.

   aMill.job_finish() # output housekeeping code
