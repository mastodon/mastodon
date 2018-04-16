# load tasks
Dir['tasks/*.rake'].sort.each { |f| load f }

# default task
task :compile => :submodules
task :default => [:compile, :spec]
