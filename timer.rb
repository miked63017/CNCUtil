#require Time
print "press enter when done to get elapsed time"
beg_t = Time.now()
inpt = gets
inpt = inpt.chomp

end_t = Time.now()
elaps = end_t - beg_t
print "elapsed = ",  elaps," Seconds \n"
print "elapsed =", elaps / 60, " Minutes\n"



