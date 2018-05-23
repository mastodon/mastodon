require "webpacker/configuration"

namespace :webpacker do
  desc "Remove the webpack compiled output directory"
  task clobber: ["webpacker:verify_install", :environment] do
    Webpacker.clobber
    $stdout.puts "Removed webpack output path directory #{Webpacker.config.public_output_path}"
  end
end

# Run clobber if the assets:clobber is run
if Rake::Task.task_defined?("assets:clobber")
  Rake::Task["assets:clobber"].enhance do
    Rake::Task["webpacker:clobber"].invoke
  end
end
