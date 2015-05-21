require 'rubygems/dependency_installer'

def already_installed(dep)
  !Gem::DependencyInstaller.new(:domain => :local).find_gems_with_sources(dep).empty? ||
    !Gem::DependencyInstaller.new(:domain => :local,:prerelease => true).find_gems_with_sources(dep).empty?
end

if RUBY_VERSION < '2.0'
  dep = Gem::Dependency.new('debugger', '> 0')
else
  dep = Gem::Dependency.new('byebug', '>= 5.0.0')
end

begin
  puts "Installing debugging gem"
  inst = Gem::DependencyInstaller.new :prerelease => dep.prerelease?
  inst.install dep
rescue
  begin
    inst = Gem::DependencyInstaller.new(:prerelease => true)
    inst.install dep
  rescue Exception => e
    puts e
    puts e.backtrace.join "\n  "
    exit(1)
  end
end unless dep.nil? || already_installed(dep)

# create dummy rakefile to indicate success
f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close
