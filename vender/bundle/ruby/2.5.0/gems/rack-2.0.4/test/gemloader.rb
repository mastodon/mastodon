require 'rubygems'
project = 'rack'
gemspec = File.expand_path("#{project}.gemspec", Dir.pwd)
Gem::Specification.load(gemspec).dependencies.each do |dep|
  begin
    gem dep.name, *dep.requirement.as_list
  rescue Gem::LoadError
    warn "Cannot load #{dep.name} #{dep.requirement.to_s}"
  end
end
