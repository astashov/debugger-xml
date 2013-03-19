require_relative '../test_helper'
require 'debugger/xml/ide/control_command_processor'

describe Debugger::Xml::Ide::ControlCommandProcessor do
  include TestDsl

  let(:klass) { Debugger::Xml::Ide::ControlCommandProcessor }
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

  it "must process a control command" do
    Debugger::AddBreakpoint.any_instance.expects(:execute).with()
    enter 'break 5'
    subject.process_commands
  end

  it "must process several commands, separated by ;" do
    Debugger::AddBreakpoint.any_instance.expects(:execute).with()
    Debugger::DeleteBreakpointCommand.any_instance.expects(:execute).with()
    enter 'break 5; delete 1'
    subject.process_commands
  end

  it "must show error if there is no such command" do
    enter 'bla'
    subject.process_commands
    check_output_includes "Unknown command: bla"
  end

  it "must show error if context is dead" do
    context.expects(:dead?).returns(true)
    enter 'step'
    subject.process_commands
    check_output_includes "Command is unavailable"
  end

  it "must show error if no suspended thread" do
    Debugger.handler.stubs(:at_line?).returns(false)
    enter 'step'
    subject.process_commands
    check_output_includes(
      "There is no thread suspended at the time and therefore no context to execute 'step'",
    interface.error_queue)
  end

  it "must run stopped thread after stepping command" do
    context.expects(:step).with(1, false)
    context.thread.expects(:run)
    enter 'step'
    subject.process_commands
  end
end
