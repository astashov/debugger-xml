require_relative '../test_helper'
require 'debugger_xml/ide/processor'

describe DebuggerXml::Ide::Processor do
  include TestDsl

  before { Thread.stubs(:stop) }

  let(:klass) { DebuggerXml::Ide::Processor }
  let(:interface) { TestInterface.new }
  let(:breakpoint) { stub }
  let(:context) { stub(thread: nil, stop_reason: nil, thnum: 1, stack_size: 2) }
  let(:file) { fullpath('jump') }
  subject { klass.new(interface, $proxy) }

  describe "#at_breakpoint" do
    it "must assign breakpoint to instance variable" do
      subject.at_breakpoint(context, breakpoint)
      subject.instance_variable_get("@last_breakpoint").must_equal breakpoint
    end

    it "must raise error if @last_breakpoint is already assigned" do
      subject.instance_variable_set("@last_breakpoint", breakpoint)
      subject.at_breakpoint(context, breakpoint)
      check_output_includes /INTERNAL ERROR!!!/
    end

    it "must not print anything" do
      subject.at_breakpoint(context, breakpoint)
      interface.must_be_empty
    end
  end

  describe "#at_line" do
    describe "print current position" do
      it "must print if context is nil" do
        subject.at_line(nil, file, 30)
        check_output_includes %{<suspended file="#{file}" line="30" threadId="" frames=""/>}
      end

      it "must print if stop reason is :step" do
        context.stubs(:stop_reason).returns(:step)
        subject.at_line(context, file, 30)
        check_output_includes %{<suspended file="#{file}" line="30" threadId="1" frames="2"/>}
      end

      it "must clear instance variables after resuming thread" do
        subject.instance_variable_set("@line", 10)
        subject.at_line(context, file, 30)
        subject.instance_variable_get("@line").must_be_nil
      end

      describe "print breakpoint after at_breakpoint" do
        before do
          $proxy.stubs(:breakpoints).returns([breakpoint])
          $proxy.stubs(:current_context).returns(stub(thnum: 1))
          subject.instance_variable_set("@last_breakpoint", breakpoint)
        end

        it "must print in plain text" do
          subject.at_line(context, file, 30)
          check_output_includes %{<breakpoint file="#{file}" line="30" threadId="1"/>}
        end
      end

      it "must show error if current thread is DebugThread" do
        context.stubs(:thread).returns($proxy.debug_thread_class.new {})
        subject.at_line(context, file, 30)
        check_output_includes /DebuggerThread are not supposed to be traced/
      end
    end
  end

  describe "#at_line?" do
    it "returns false if #at_line was not called yet" do
      subject.at_line?.must_equal false
    end

    it "returns true if #at_line was called already" do
      subject.instance_variable_set("@line", 10)
      subject.at_line?.must_equal true
    end
  end

  describe "#at_return?" do
    before { context.stubs(:stop_frame=).with(-1) }

    it "sets stop_frame to -1" do
      context.expects(:stop_frame=).with(-1)
      subject.at_return(context, file, 30)
    end

    it "prints current file and line" do
      subject.at_return(context, file, 30)
      check_output_includes %{<suspended file="#{file}" line="30" threadId="1" frames="2"/>}
    end

    it "stops the thread" do
      Thread.expects(:stop)
      subject.at_return(context, file, 30)
    end
  end

end
