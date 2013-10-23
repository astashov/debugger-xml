if ENV['IDE_PROCESS_DISPATCHER']
  require 'rubygems'
  ENV['DEBUGGER_STORED_RUBYLIB'].split(File::PATH_SEPARATOR).each do |path|
    $LOAD_PATH << path
  end
  require 'debugger/xml'
  Debugger::Xml::MultiProcess::pre_child
end
