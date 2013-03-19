require_relative '../test_helper'
require 'debugger/xml/vim/notification'

describe Debugger::Xml::Vim::Notification do
  include TestDsl

  let(:klass) { Debugger::Xml::Vim::Notification }
  let(:options) do
    stub(vim_executable: "vim", vim_servername: "VIM", debug_mode: true, logger_file: filename)
  end
  let(:subject) { klass.new("foo", options) }
  let(:filename) { File.expand_path("../tmp", __FILE__) }
  let(:command) { %{vim --servername VIM -u NONE -U NONE --remote-send \"<C-\\\\><C-N>:call RubyDebugger.foo()<CR>\"} }

  before do
    File.open(filename, 'w') { |f| }
  end

  after do
    File.unlink(filename)
  end

  it "must send command to Vim" do
    subject.stubs(:log)
    subject.expects(:system).with(command)
    subject.send
  end

  it "must log to file" do
    subject.stubs(:system).with(command)
    subject.send
    File.read(filename).must_match /Executing command: vim --servername/
  end
end
