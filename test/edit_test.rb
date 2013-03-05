require_relative 'test_helper'

describe "Edit Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must be unsupported for XML printer" do
    enter 'edit'
    debug_file 'edit'
    check_output_includes "<error>Unsupported command 'edit'</error>", interface.error_queue
  end
end
