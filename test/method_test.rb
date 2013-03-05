require_relative 'test_helper'

describe "Method Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  describe "show instance method of a class" do
    it "must show using full command name" do
      enter 'break 15', 'cont', 'm MethodEx'
      debug_file 'method'
      check_output_includes '<methods><method name="bla"/></methods>'
    end
  end

  describe "show methods of an object" do
    it "must show using full command name" do
      enter 'break 15', 'cont', 'method instance a'
      debug_file 'method'
      check_output_includes /<methods>.*<method name="bla"\/>.*<\/methods>/
    end
  end

  describe "show instance variables of an object" do
    it "must show using full name command" do
      enter 'break 15', 'cont', 'method iv a'
      debug_file 'method'
      check_output_includes(Regexp.new(
        %{<variables>} +
          %{<variable name="@a" kind="instance" value="b" type="String" hasChildren="false" objectId=".*?"/>} +
          %{<variable name="@c" kind="instance" value="d" type="String" hasChildren="false" objectId=".*?"/>} +
        %{</variables>}
      ))
    end
  end

end
