require 'minitest/autorun'

require 'debugger/xml'
require 'debugger/test'

$debugger_test_dir = File.expand_path("..", __FILE__)
Debugger::Xml.logger = Debugger::Xml::FakeLogger.new
