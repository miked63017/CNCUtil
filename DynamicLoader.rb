# cncDynamicLoader.rb
# Dynamic loader functionality that 
# can be mixed into existing classes.
#
#  Used to allow external files to contain
#   defenitions for a specific instance 
#   such as a material that has different
#   constants for each differnt kind of
#   material but no functionality changes.
#   this could obviously be done in config file
#   like INI or XML but it seemed easier to use
#   the built in ruby interpreter instead.
#   
#   The design is such that the config code 
#   makes a series of = "setter" calls to the
#   instance methods.
# 
#   The class which calls load_file must have
#   a setter defined for every self. variable
#   defined in the config file.   For example
#   if the config file contains the line 
#   self.max_z = 10 defined then the class 
#   which loaded that config must have  a 
#   def max_z=(aNum) setter method defined.
#  
#
module DynamicLoader
  def load_file(load_fi_name)
  
    if (load_fi_name == nil)
      return false
    end #if
     
    # TODO: Add a check for file exists
    # before attempting the open.
  
    f = open(load_fi_name, "r")
    begin
      f.each_line do |line|
        #print "line=", line
        eval(line)
    end
    ensure
      f.close
    end
    return true
  end #load
  
 
end #module   