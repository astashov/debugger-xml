require_relative 'test_helper'

describe "Help Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must be unsupported for XML printer" do
    enter 'help'
    debug_file 'help'
    check_output_includes "<error>Unsupported command 'help'</error>", interface.error_queue
  end

end
