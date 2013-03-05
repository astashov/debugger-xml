require_relative 'test_helper'

describe "Thread Command" do
  include TestDsl
  temporary_change_method_value(Debugger, :printer, Printers::Xml.new)
  let(:release) { 'eval Thread.main[:should_break] = true' }

  it "must show current thread by 'plus' sign" do
    thnum = nil
    enter 'break 8', 'cont', 'thread list', release
    debug_file('thread') { thnum = Debugger.contexts.first.thnum }
    check_output_includes %{<threads><thread id="#{thnum}" status="run" current="yes"/></threads>}
  end

  it "must show 3 available threads" do
    enter 'break 21', 'cont', 'thread list', release
    debug_file 'thread'
    check_output_includes /<threads>.*<thread .*<thread .*><thread .*><\/threads>/
  end
end
