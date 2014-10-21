# test_loader_1.rb

#  See (C) notice in http://xdobs.com/cnc/CNCUtil/license.txt for license and copyright.

class Test_loader

  def funcx
    print "calling funtz\n"
  end #meth

  def bitz(oi)
    print "calling bitz oi=", oi, "\n"
  end #meth

  def bit_size=(oi)
    @bit_size = oi
    print "bit_size=", @bit_size
  end

  def initialize(load_fi)
    f = open(load_fi, "r")
    begin
      f.each_line do |line|
        print "line=", line
        eval(line)
      end
    ensure
      f.close
    end
 
 
    @fi_name = load_fi
    
    #eval("test_var=98\n@ttv=97", self)

    #print "test_var=", test_var, " @ttv=", @ttv, "\n"
   
    print "XXXX\n"
    eval("print load_fi")
    print "YYYY\n"

    eval("self.funcx")

    load(load_fi)

    #print "bit_dens=", bit_dens, "  @bit_size=", @bit_size, "\n"
  end #meth init


  def prints
    print "@fi_name=", @fi_name, " @bit_size=", @bit_size, "\n"
  end #meth
    

end #class



aio1 = Test_loader.new("test_loader_2.rb")
aio2 = Test_loader.new("test_loader_3.rb")


print "aio1=\n"
aio1.prints

print "aio2=\n"
aio2.prints

