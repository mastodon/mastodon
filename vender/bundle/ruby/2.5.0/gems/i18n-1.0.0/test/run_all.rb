def bundle_check
  `bundle check` == "Resolving dependencies...\nThe Gemfile's dependencies are satisfied\n"
end

def execute(command)
  puts command
  system command
end

gemfiles = %w(Gemfile) + Dir['gemfiles/Gemfile*'].reject { |f| f.end_with?('.lock') }

results = gemfiles.map do |gemfile|
  puts "\nBUNDLE_GEMFILE=#{gemfile}"
  ENV['BUNDLE_GEMFILE'] = File.expand_path("../../#{gemfile}", __FILE__)

  execute 'bundle install' unless bundle_check
  execute 'bundle exec rake test'
end

exit results.all?
