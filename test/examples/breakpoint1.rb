class A
  def self.a
    4
  end
  def b
    3
  end
end

a = 3
# A comment
debugger
b = 5
c = a + b
load Pathname.new(__FILE__ + "/../breakpoint2.rb").cleanpath