require 'minitest/autorun'

DEBUGGER_TYPE = :debugger
require 'debugger'
require 'debugger_xml'

$debugger_test_dir = File.expand_path("..", __FILE__)
$proxy = DebuggerXml::DebuggerProxy.new

MiniTest::Unit::TestCase.add_setup_hook do
  $proxy.printer = Printers::Xml.new
end

require 'debugger/test'

DebuggerXml.logger = DebuggerXml::FakeLogger.new
