require_relative 'test_helper'

describe "Irb Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must be unsupported for XML printer" do
    enter 'irb'
    debug_file 'irb'
    check_output_includes "<error>Unsupported command 'irb'</error>", interface.error_queue
  end
end
