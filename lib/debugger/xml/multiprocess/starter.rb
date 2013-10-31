if ENV['IDE_PROCESS_DISPATCHER']
  require 'rubygems'
  # todo: do we need these lines?
  ENV['DEBUGGER_STORED_RUBYLIB'].split(File::PATH_SEPARATOR).each do |path|
    next unless path =~ /debugger-xml|\/debugger\/|linecache/
    $LOAD_PATH << path
  end
  require 'debugger/xml'
  Debugger::Xml::MultiProcess.pre_child
end
