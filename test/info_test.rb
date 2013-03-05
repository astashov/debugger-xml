require_relative 'test_helper'

describe "Info Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must be unsupported for XML printer" do
    enter 'info line'
    debug_file 'info'
    check_output_includes "<error>Unsupported command 'info'</error>", interface.error_queue
  end
end
