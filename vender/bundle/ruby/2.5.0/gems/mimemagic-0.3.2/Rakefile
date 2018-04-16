task :default => %w(test)

desc 'Run tests with bacon'
task :test => FileList['test/*_test.rb'] do |t|
  sh "bacon -q -Ilib:test #{t.prerequisites.join(' ')}"
end

desc 'Generate mime tables'
task :tables => 'lib/mimemagic/tables.rb'
file 'lib/mimemagic/tables.rb' => FileList['script/freedesktop.org.xml'] do |f|
  sh "script/generate-mime.rb #{f.prerequisites.join(' ')} > #{f.name}"
end

