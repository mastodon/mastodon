begin
  require "bundler/gem_tasks"
rescue LoadError
  puts "Bundler not available. Install it with: gem install bundler"
end

Dir[File.join(File.dirname(__FILE__), "lib/tasks/*.rake")].sort.each { |ext| load ext }
