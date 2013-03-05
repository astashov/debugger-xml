require_relative 'test_helper'

describe "Reload Command" do
  include TestDsl
  temporary_change_hash_value(Debugger::Command.settings, :reload_source_on_change, false)
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "must notify that automatic reloading is off" do
    enter 'reload'
    debug_file 'reload'
    check_output_includes "<message>Source code is reloaded. Automatic reloading is off</message>"
  end

end
