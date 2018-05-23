require "webpacker/configuration"

namespace :webpacker do
  desc "Verifies if Webpacker is installed"
  task verify_install: [:check_node, :check_yarn, :check_binstubs] do
    if Webpacker.config.config_path.exist?
      $stdout.puts "Webpacker is installed 🎉 🍰"
      $stdout.puts "Using #{Webpacker.config.config_path} file for setting up webpack paths"
    else
      $stderr.puts "Configuration config/webpacker.yml file not found. \n"\
           "Make sure webpacker:install is run successfully before " \
           "running dependent tasks"
      exit!
    end
  end
end
