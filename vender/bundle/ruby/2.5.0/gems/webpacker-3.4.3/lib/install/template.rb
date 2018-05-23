# Install Webpacker
copy_file "#{__dir__}/config/webpacker.yml", "config/webpacker.yml"

puts "Copying webpack core config"
directory "#{__dir__}/config/webpack", "config/webpack"

say "Copying .postcssrc.yml to app root directory"
copy_file "#{__dir__}/config/.postcssrc.yml", ".postcssrc.yml"

say "Copying .babelrc to app root directory"
copy_file "#{__dir__}/config/.babelrc", ".babelrc"

say "Creating JavaScript app source directory"
directory "#{__dir__}/javascript", Webpacker.config.source_path

apply "#{__dir__}/binstubs.rb"

say "Adding configurations"

check_yarn_integrity_config = ->(value) { <<CONFIG }
# Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = #{value}
CONFIG

if Rails::VERSION::MAJOR >= 5
  environment check_yarn_integrity_config.call("true"), env: :development
  environment check_yarn_integrity_config.call("false"), env: :production
else
  inject_into_file "config/environments/development.rb", "\n  #{check_yarn_integrity_config.call("true")}", after: "Rails.application.configure do", verbose: false
  inject_into_file "config/environments/production.rb", "\n  #{check_yarn_integrity_config.call("false")}", after: "Rails.application.configure do", verbose: false
end

if File.exists?(".gitignore")
  append_to_file ".gitignore", <<-EOS
/public/packs
/public/packs-test
/node_modules
yarn-debug.log*
.yarn-integrity
EOS
end

say "Installing all JavaScript dependencies"
run "yarn add @rails/webpacker@3.4 --tilde"

say "Installing dev server for live reloading"
run "yarn add --dev webpack-dev-server@2.11.2"

if Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR > 1
  say "You need to allow webpack-dev-server host as allowed origin for connect-src.", :yellow
  say "This can be done in Rails 5.2+ for development environment in the CSP initializer", :yellow
  say "config/initializers/content_security_policy.rb with a snippet like this:", :yellow
  say "p.connect_src :self, :https, \"http://localhost:3035\", \"ws://localhost:3035\" if Rails.env.development?", :yellow
end

say "Webpacker successfully installed 🎉 🍰", :green
