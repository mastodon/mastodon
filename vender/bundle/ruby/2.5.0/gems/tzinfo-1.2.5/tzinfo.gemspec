Gem::Specification.new do |s|
  s.name = 'tzinfo'
  s.version = '1.2.5'
  s.summary = 'Daylight savings aware timezone library'
  s.description = 'TZInfo provides daylight savings aware transformations between times in different time zones.'
  s.author = 'Philip Ross'
  s.email = 'phil.ross@gmail.com'
  s.homepage = 'http://tzinfo.github.io'
  s.license = 'MIT' 
  s.files = %w(CHANGES.md LICENSE Rakefile README.md tzinfo.gemspec .yardopts) +
            Dir['lib/**/*.rb'].delete_if {|f| f.include?('.svn')} +
            Dir['test/**/*.rb'].delete_if {|f| f.include?('.svn')} +
            Dir['test/zoneinfo/**/*'].delete_if {|f| f.include?('.svn') || File.symlink?(f)}
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rdoc_options << '--title' << 'TZInfo' << 
                    '--main' << 'README.md'
  s.extra_rdoc_files = ['README.md', 'CHANGES.md', 'LICENSE']
  s.required_ruby_version = '>= 1.8.7'
  s.add_dependency 'thread_safe', '~> 0.1'
end
