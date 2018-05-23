desc "Load environment settings from .env"
task :dotenv do
  require "dotenv"
  Dotenv.load
end

task environment: :dotenv
