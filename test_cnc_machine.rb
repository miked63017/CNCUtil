# test_cnc_machine.rb
# use to test the dynmaic loader for CNCMachine.
#
require 'CNCMachine'
require 'CNCMaterial'
require 'CNCJob'
require 'CNCMill'

aMill = CNCMill.new()


aMachine = CNCMachine.new(aMill)
print "max_z=", aMachine.max_z


aMaterial = CNCMaterial.new(aMill)

aJob = CNCJob.new(aMill)
aBit = aMill.current_bit
aDiam = 0.123

print "\n"
print "aDiam = ", aDiam, "\n"

bn = aMaterial.get_closest_bit_no(0.123)
print "bn bit num= ", bn, "\n"

rpm = aMaterial.get_rpm(0.123)
print "rpm=", rpm, "\n"

cpt = aMaterial.get_cut_per_tooth(0.123)
print "cpt = ", cpt, "\n"

ips = aMill.current_bit.get_inch_per_sec(aMaterial)
print "aBit ips =", ips, "\n"

ipa = aMaterial.get_inch_per_sec(aMill.current_bit, rpm)
print "ipa = ", ipa, "\n"

print "inches per minute = ",  ips * 60, "\n"

cut_depth = aMaterial.get_cut_depth_inc(aDiam)
print "cut depth increment =",   cut_depth, "\n"

fspeed = aMachine.get_fspeed_from_IPS(ips)
print "fspeed = ", fspeed, "\n"

fpseedb = aBit.get_fspeed()
print "fspeed from bit = ", fpseedb, "\n"

sfm = rpm * aBit.diam * 0.262
print "sfm surface foot per minute= ", sfm, "\n"



# actual surface foot per minute

# cubic foot per minute removed


