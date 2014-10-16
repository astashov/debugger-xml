require_relative '../test_helper'
require 'debugger_xml/vim/control_command_processor'

describe DebuggerXml::Vim::ControlCommandProcessor do
  include TestDsl

  let(:klass) { DebuggerXml::Vim::ControlCommandProcessor }
  let(:interface) { Debugger.handler.interface }
  let(:file) { fullpath('jump') }
  let(:context) { stub(frame_binding: stub, stop_reason: nil, thread: stub, thnum: 1, stack_size: 2, dead?: false) }
  subject { klass.new(interface, $proxy) }

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
