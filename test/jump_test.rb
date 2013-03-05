require_relative 'test_helper'

describe "Jump Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  describe "successful" do
    describe "jumping to the same line" do
      it "must show show the same position" do
        enter 'break 6', 'cont', "jump 6 #{fullpath('jump')}"
        debug_file('jump')
        check_output_includes /<suspended file="#{fullpath('jump')}" line="6" threadId="\d+" frames="\d+"\/>/
      end
    end

    it "must show message after jump" do
      enter 'break 6', 'cont', "jump 8 #{fullpath('jump')}"
      debug_file('jump')
      check_output_includes /<suspended file="#{fullpath('jump')}" line="8" threadId="\d+" frames="\d+"\/>/
    end
  end
end
