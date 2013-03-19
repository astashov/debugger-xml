require_relative '../test_helper'
require 'debugger/xml/vim/control_command_processor'

describe Debugger::Xml::Vim::ControlCommandProcessor do
  include TestDsl

  let(:klass) { Debugger::Xml::Vim::ControlCommandProcessor }
  let(:interface) { Debugger.handler.interface }
  let(:file) { fullpath('jump') }
  let(:context) { stub(frame_binding: stub, stop_reason: nil, thread: stub, thnum: 1, stack_size: 2, dead?: false) }
  subject { klass.new(interface) }
  temporary_change_method_value(Debugger, :handler, Debugger::Xml::Ide::Processor.new(TestInterface.new))

  before do
    Thread.stubs(:stop)
    Debugger.handler.instance_variable_set("@context", context)
    Debugger.handler.instance_variable_set("@file", file)
    Debugger.handler.instance_variable_set("@line", 30)
  end

  it "must send response after executing commands" do
    Debugger::AddBreakpoint.any_instance.stubs(:execute).with()
    Debugger::DeleteBreakpointCommand.any_instance.stubs(:execute).with()
    interface.expects(:send_response)
    enter 'break 5; delete 1'
    subject.process_commands
  end
end
