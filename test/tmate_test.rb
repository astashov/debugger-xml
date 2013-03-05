if RUBY_PLATFORM =~ /darwin/
require_relative 'test_helper'

describe "Tmate Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must be unsupported for XML printer" do
    enter 'tmate'
    debug_file 'tmate'
    check_output_includes "<error>Unsupported command 'tmate'</error>", interface.error_queue
  end

end
end
