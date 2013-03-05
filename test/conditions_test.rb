require_relative 'test_helper'

describe "Conditions" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  describe "setting condition" do
    it "must show a successful message" do
      enter 'break 3', ->{"cond #{breakpoint.id} b == 5"}, "cont"
      id = nil
      debug_file('conditions') { id = breakpoint.id }
      check_output_includes "<conditionSet bp_id=\"#{id}\"/>"
    end
  end

  describe "removing conditions" do
    it "must show a successful message" do
      enter "break 3 if b == 3", "break 4", ->{"cond #{breakpoint.id}"}, "cont"
      id = nil
      debug_file('conditions') { id = breakpoint.id }
      check_output_includes "<conditionSet bp_id=\"#{id}\"/>"
    end
  end

  describe "errors" do
    it "must show error if there are no breakpoints" do
      enter 'cond 1 true'
      debug_file('conditions')
      check_output_includes "<error>No breakpoints have been set</error>"
    end
  end
end
