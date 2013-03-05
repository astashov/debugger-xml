require_relative 'test_helper'

describe "Display Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)

  it "displays all expressions available" do
    enter 'break 3', 'cont', -> do
      Debugger.handler.display.concat([[true, "abc"], [true, "d"]]); 'display'
    end
    debug_file('display')
    check_output_includes '<displays><display key="abc" value=""/><display key="d" value="4"/></displays>'
  end

  describe "undisplay all" do
    it "must ask about confirmation" do
      enter 'break 3', 'cont', -> do
        Debugger.handler.display.concat([[true, "abc"], [true, "d"]])
        'undisplay'
      end, 'y', 'display'
      debug_file('display')
      check_output_includes "<confirmation>Clear all expressions?</confirmation>", interface.confirm_queue
    end
  end
end
