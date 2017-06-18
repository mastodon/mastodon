#!/usr/bin/env ruby
$stdout.sync = true

require "shellwords"
require "yaml"

ENV["RAILS_ENV"] ||= "development"
RAILS_ENV = ENV["RAILS_ENV"]

ENV["NODE_ENV"] ||= RAILS_ENV
NODE_ENV = ENV["NODE_ENV"]

APP_PATH          = File.expand_path("../", __dir__)
NODE_MODULES_PATH = File.join(APP_PATH, "node_modules")
WEBPACK_CONFIG    = File.join(APP_PATH, "config/webpack/#{NODE_ENV}.js")

unless File.exist?(WEBPACK_CONFIG)
  puts "Webpack configuration not found."
  puts "Please run bundle exec rails webpacker:install to install webpacker"
  exit!
end

newenv  = { "NODE_PATH" => NODE_MODULES_PATH.shellescape }
cmdline = ["yarn", "run", "webpack", "--", "--config", WEBPACK_CONFIG] + ARGV

Dir.chdir(APP_PATH) do
  exec newenv, *cmdline
end
