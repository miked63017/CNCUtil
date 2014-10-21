   # ex_simple_raise_lower_head.rb
   #  See (C) notice in http://CNCUtil.org/license.txt for license and copyright.
   require 'CNCMill'
   aMill = CNCMill.new
   aMill.job_start()
   aMill.retract()
   aMill.plung()
   aMill.retract(0.6)
   aMill.plung(-1.5)
   aMill.home()
      # Home performs a retract() before moving the
      # head from it's current position to it's home
      # position. 
   aMill.job_finish()
