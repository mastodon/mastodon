begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  warn "warning: simplecov gem not found; skipping coverage"
end

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")
$LOAD_PATH << File.join(File.dirname(__FILE__))

require "rubygems"
require "rspec"
require "climate_control"
