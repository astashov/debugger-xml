require_relative 'test_helper'

describe "Continue Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must show error if there is no specified line" do
    enter 'cont 123'
    debug_file('continue')
    check_output_includes "<error>Line 123 is not a stopping point in file '#{fullpath('continue')}'</error>", interface.error_queue
  end
end
