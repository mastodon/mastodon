require 'rake/testtask'

task default: :test
task :test do
  sh "bacon -Ilib -Itest --automatic --quiet"
end

#Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib' << 'test'
#  t.pattern = 'test/**/test_*.rb'
#  t.verbose = false
#end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'lib' << 'test'
    t.pattern = 'test/**/test_*.rb'
    t.verbose = false
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: gem install rcov"
  end
end
