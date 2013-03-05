require_relative 'test_helper'

describe "Set Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must show a message after setting" do
    enter 'set autolist on'
    debug_file 'set'
    check_output_includes "<message>autolist is on</message>"
  end
end
