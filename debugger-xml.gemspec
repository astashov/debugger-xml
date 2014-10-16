# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'debugger_xml/version'

Gem::Specification.new do |gem|
  gem.name          = "debugger-xml"
  gem.version       = DebuggerXml::VERSION
  gem.authors       = ["Anton Astashov"]
  gem.email         = ["anton.astashov@gmail.com"]
  gem.description   = %q{XML interface for debugger}
  gem.summary       = %q{Implements XML interface for the 'debugger' gem, compatible with ruby-debug-ide gem}
  gem.homepage      = ""
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'builder', '>= 2.0.0'
  gem.add_development_dependency 'rake', '~> 0.9.2.2'
  gem.add_development_dependency 'minitest', '~> 2.12.1'
  gem.add_development_dependency 'mocha', '~> 0.13.0'
end
