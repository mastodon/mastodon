require "webpacker/configuration"

say "Copying angular example entry file to #{Webpacker.config.source_entry_path}"
copy_file "#{__dir__}/examples/angular/hello_angular.js", "#{Webpacker.config.source_entry_path}/hello_angular.js"

say "Copying hello_angular app to #{Webpacker.config.source_path}"
directory "#{__dir__}/examples/angular/hello_angular", "#{Webpacker.config.source_path}/hello_angular"

say "Installing all angular dependencies"
run "yarn add core-js zone.js rxjs @angular/core @angular/common @angular/compiler @angular/platform-browser @angular/platform-browser-dynamic"

if Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR > 1
  say "You need to enable unsafe-eval rule.", :yellow
  say "This can be done in Rails 5.2+ for development environment in the CSP initializer", :yellow
  say "config/initializers/content_security_policy.rb with a snippet like this:", :yellow
  say "if Rails.env.development?", :yellow
  say "  p.script_src :self, :https, :unsafe_eval", :yellow
  say "else", :yellow
  say "  p.script_src :self, :https", :yellow
  say "end", :yellow
end

say "Webpacker now supports angular 🎉", :green
