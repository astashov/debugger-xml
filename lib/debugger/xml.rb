require "debugger"
require "debugger/printers/xml"
Dir.glob(File.expand_path("../**/*.rb", __FILE__)).each { |f| require f }
