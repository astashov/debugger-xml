debugger
class VariablesXmlExample
  SOMECONST = 'foo' unless defined?(SOMECONST)

  def initialize
    @a = "b"
  end

  class VariablesXmlNested
    def initialize
      $glob = 100
      @inst_a = [1, 2, 3]
      @inst_b = 2
      @inst_c = "123"
      @inst_d = BasicObject.new
      @@class_c = 3
    end
  end

  def run
    a = VariablesXmlNested.new
    b = [1, 2, 3]
    c = {:a => 'b', 'c' => 'd'}
    c
  end

end

v = VariablesXmlExample.new
v.run
v
