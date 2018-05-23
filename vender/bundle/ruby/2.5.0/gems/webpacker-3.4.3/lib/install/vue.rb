require "webpacker/configuration"

say "Copying vue loader to config/webpack/loaders"
copy_file "#{__dir__}/loaders/vue.js", Rails.root.join("config/webpack/loaders/vue.js").to_s

say "Adding vue loader to config/webpack/environment.js"
insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "const vue =  require('./loaders/vue')\n",
  after: "require('@rails/webpacker')\n"

insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "environment.loaders.append('vue', vue)\n",
  before: "module.exports"

say "Updating webpack paths to include .vue file extension"
insert_into_file Webpacker.config.config_path, "    - .vue\n", after: /extensions:\n/

say "Copying the example entry file to #{Webpacker.config.source_entry_path}"
copy_file "#{__dir__}/examples/vue/hello_vue.js",
  "#{Webpacker.config.source_entry_path}/hello_vue.js"

say "Copying Vue app file to #{Webpacker.config.source_entry_path}"
copy_file "#{__dir__}/examples/vue/app.vue",
  "#{Webpacker.config.source_path}/app.vue"

say "Installing all Vue dependencies"
run "yarn add vue vue-loader vue-template-compiler"

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

say "Webpacker now supports Vue.js 🎉", :green
