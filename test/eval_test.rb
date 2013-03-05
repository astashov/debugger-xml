require_relative 'test_helper'

describe "Eval Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must evaluate an expression" do
    enter 'eval 3 + 2'
    debug_file 'eval'
    check_output_includes '<eval expression="3 + 2" value="5"/>'
  end

  it "must evaluate with error" do
    enter 'eval blabla'
    debug_file 'eval'
    check_output_includes(
      %{<processingException type="NameError" message="undefined local variable or method `blabla' for main:Object"/>},
    interface.error_queue)
  end
end
