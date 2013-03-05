require_relative 'test_helper'

describe "Trace Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must be unsupported for XML printer" do
    enter 'trace on'
    debug_file 'trace'
    check_output_includes "<error>Unsupported command 'trace'</error>", interface.error_queue
  end
end
