require_relative '../test_helper'
require 'debugger_xml/vim/interface'

describe DebuggerXml::Vim::Interface do
  include TestDsl

  let(:klass) { DebuggerXml::Vim::Interface }
  let(:options) do
    stub(debug_mode: false, file: filename, separator: "--sep--")
  end
  let(:socket) { stub }
  let(:subject) { klass.new(socket, options) }
  let(:filename) { File.expand_path("../tmp", __FILE__) }
  let(:notification) { stub(send: nil) }

  before do
    File.open(filename, 'w') { |f| }
  end

  after do
    File.unlink(filename)
  end

  it "must send command to Vim" do
    DebuggerXml::Vim::Notification.expects(:new).with("receive_command", options).returns(notification)
    subject.print("foo")
    subject.print("bar")
    subject.send_response
    File.read(filename).strip.must_equal "foo--sep--bar"
  end

  it "must clear the queue after sending response" do
    DebuggerXml::Vim::Notification.stubs(:new).with("receive_command", options).returns(notification)
    subject.print("foo")
    subject.print("bar")
    subject.send_response
    subject.print("bla")
    subject.send_response
    File.read(filename).strip.must_equal "bla"
  end

  it "must not send any command if there is nothing to send" do
    DebuggerXml::Vim::Notification.expects(:new).never
    subject.send_response
    File.read(filename).strip.must_equal ""
  end
end
