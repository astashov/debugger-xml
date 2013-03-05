require_relative 'test_helper'

describe "Kill Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must be unsupported for XML printer" do
    enter 'kill'
    debug_file 'kill'
    check_output_includes "<error>Unsupported command 'kill'</error>", interface.error_queue
  end

end
