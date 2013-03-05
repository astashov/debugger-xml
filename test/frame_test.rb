require_relative 'test_helper'

describe "Frame Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must print current stack frame when without arguments" do
    enter 'break 25', 'cont', 'up', 'frame'
    debug_file('frame')
    check_output_includes %{<frame no="0" file="#{fullpath('frame')}" line="25" current="false"/>}
  end

  describe "full path settings" do
    temporary_change_hash_value(Debugger::Command.settings, :full_path, false)

    it "must display current backtrace with full path = true" do
      enter 'set fullpath', 'break 25', 'cont', 'where'
      debug_file('frame')
      check_output_includes(Regexp.new(
        "<frames>" +
          %{<frame no="0" file="#{fullpath('frame')}" line="25" current="true"/>} +
          %{<frame no="1" file="#{fullpath('frame')}" line="21" current="false"/>} +
          %{<frame no="2" file="#{fullpath('frame')}" line="17" current="false"/>} +
          %{<frame no="3" file="#{fullpath('frame')}" line="14" current="false"/>.*} +
        "</frames>",
      Regexp::MULTILINE))
    end
  end
end
