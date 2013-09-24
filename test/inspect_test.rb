require_relative 'test_helper'

describe "Inspect Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must inspect ENV" do
    enter 'break 25', 'cont', 'v inspect ENV'
    debug_file 'variables'
    check_output_includes(Regexp.new(
        '<variables>' +
          %{<variable name="eval_result" kind="local" value="ENV" type="Object" hasChildren="false" objectId=".*"/>} +
        '</variables>'
      ))
  end

  it "must inspect an arithmetic expression" do
    enter 'break 25', 'cont', 'v inspect 1 + 2'
    debug_file 'variables'
    check_output_includes(Regexp.new(
        '<variables>' +
          %{<variable name="eval_result" kind="local" value="3" type="Fixnum" hasChildren="false" objectId=".*"/>} +
        '</variables>'
      ))
  end

  it "must inspect a hash" do
    enter 'break 25', 'cont', 'v inspect {a: 1, b: [2, 3] }'
    debug_file 'variables'
    check_output_includes(Regexp.new(
        '<variables>' +
          %{<variable name="eval_result" kind="local" value="Hash \\(2 element\\(s\\)\\)" type="Hash" hasChildren="true" objectId=".*"/>} +
        '</variables>'
      ))
  end

  it "must evaluate with error" do
    enter 'break 25', 'cont', 'v inspect blabla'
    debug_file 'variables'
    check_output_includes(
      %{<processingException type="NameError" message="undefined local variable or method `blabla' for main:Object"/>},
    interface.error_queue)
  end
end
