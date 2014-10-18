require_relative '../test_helper'
require 'debugger_xml/vim/processor'

describe DebuggerXml::Vim::Processor do
  include TestDsl

  before { Thread.stubs(:stop) }

  let(:klass) { DebuggerXml::Vim::Processor }
  let(:interface) { TestInterface.new }
  let(:breakpoint) { stub }
  let(:context) { stub(thread: nil, stop_reason: nil, thnum: 1, stack_size: 2) }
  let(:file) { fullpath('jump') }
  subject { klass.new(interface, $proxy) }

  describe "#at_line" do
    it "must send response" do
      processor = stub
      processor.stubs(:process_command).with("where")
      processor.stubs(:process_command).with("var ide")
      DebuggerXml::Vim::ControlCommandProcessor.stubs(:new).with(interface, $proxy).returns(processor)
      interface.expects(:send_response)
      subject.at_line(context, file, 30)
    end

    it "must process additional commands" do
      processor = stub
      processor.expects(:process_command).with("where")
      processor.expects(:process_command).with("var ide")
      DebuggerXml::Vim::ControlCommandProcessor.expects(:new).with(interface, $proxy).returns(processor)
      interface.stubs(:send_response)
      subject.at_line(context, file, 30)
    end
  end
end

