require 'rubygems'
require 'spec'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib"), File.join(File.dirname(__FILE__), "..", "build", RUBY_VERSION) unless RUBY_PLATFORM =~ /java/
require "ffi"

