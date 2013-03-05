require_relative 'test_helper'

describe "Stepping Commands" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  describe "Next Command" do
    it "must show the suspended line in xml" do
      enter 'break 10', 'cont', 'next+'
      debug_file('stepping')
      check_output_includes /<suspended file=".*stepping.rb" line="11" threadId="\d+" frames="\d+"\/>/
    end
  end

end
