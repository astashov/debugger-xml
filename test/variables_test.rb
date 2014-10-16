require_relative 'test_helper'

describe "Variables Command" do
  include TestDsl

  describe "constants" do
    it "must show constants" do
      enter 'break 25', 'cont', 'var const VariablesExample'
      debug_file 'variables'
      check_output_includes(Regexp.new(
        '<variables>' +
          %{<variable name="SOMECONST" kind="constant" value="foo" type="String" hasChildren="false" objectId=".*"/>} +
        '</variables>'
      ))
    end
  end

  describe "globals" do
    it "must show global variables" do
      enter 'break 25', 'cont', 'var global'
      debug_file 'variables'
      check_output_includes(Regexp.new(
        "<variables>.*" +
          %{<variable name="\\$glob" kind="instance" value="100" type="String" hasChildren="false" objectId="[^"]+"/>} +
        ".*</variables>"
      ))
    end
  end

  describe "instance variables" do
    it "must show instance variables of the given object" do
      enter 'break 22', 'cont', 'var instance a'
      debug_file 'variables_xml'
      [
        %{<variable name="@inst_a" kind="instance" value="Array \\(3 element\\(s\\)\\)" type="Array" hasChildren="true" objectId=".*"/>},
        %{<variable name="@inst_b" kind="instance" value="2" type="Fixnum" hasChildren="false" objectId="\\+0x5"/>},
        %{<variable name="@inst_c" kind="instance" value="123" type="String" hasChildren="false" objectId=".*"/>},
        %{<variable name="@inst_d" kind="instance" value="&lt;raised exception.*" type="Undefined" hasChildren="false" objectId=""/>},
        %{<variable name="@@class_c" kind="class" value="3" type="Fixnum" hasChildren="false" objectId="\\+0x7"/>}
      ].each do |regexp_string|
        check_output_includes(Regexp.new(regexp_string))
      end
    end

    it "must show array" do
      enter 'break 23', 'cont', ->{"var instance #{eval('"%#+x" % b.object_id', binding)}"}
      debug_file 'variables_xml'
      check_output_includes(
        "<variables>" +
          %{<variable name="[0]" kind="instance" value="1" type="Fixnum" hasChildren="false" objectId="+0x3"/>} +
          %{<variable name="[1]" kind="instance" value="2" type="Fixnum" hasChildren="false" objectId="+0x5"/>} +
          %{<variable name="[2]" kind="instance" value="3" type="Fixnum" hasChildren="false" objectId="+0x7"/>} +
        "</variables>"
      )
    end

    it "must show hash" do
      enter 'break 24', 'cont', ->{"var instance #{eval('"%#+x" % c.object_id', binding)}"}
      debug_file 'variables_xml'
      check_output_includes(Regexp.new(
        "<variables>" +
          %{<variable name="a" kind="instance" value="b" type="String" hasChildren="false" objectId=".*"/>} +
          %{<variable name="'c'" kind="instance" value="d" type="String" hasChildren="false" objectId=".*"/>} +
        "</variables>"
      ))
    end
  end

  describe "local variables" do
    it "must show local variables" do
      enter 'break 17', 'cont', 'var local'
      debug_file 'variables'
      check_output_includes(Regexp.new(
        "<variables>" +
          %{<variable name="self" kind="instance" value="#&lt;VariablesExample:[^"]+&gt;" type="VariablesExample" hasChildren="true" objectId="[^"]+"/>} +
          %{<variable name="a" kind="instance" value="4" type="Fixnum" hasChildren="false" objectId="[^"]+"/>} +
          %{<variable name="b" kind="instance" value="nil" type="NilClass" hasChildren="false" objectId="[^"]+"/>} +
          %{<variable name="i" kind="instance" value="1" type="Fixnum" hasChildren="false" objectId="[^"]+"/>} +
        "</variables>"
      ))
    end
  end
end
