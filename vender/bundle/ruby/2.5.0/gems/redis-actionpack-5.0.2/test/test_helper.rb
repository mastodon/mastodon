require 'bundler/setup'
require 'minitest/autorun'
require 'active_support/core_ext/numeric/time'

ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

def with_autoload_path(path)
  path = File.join(File.dirname(__FILE__), "fixtures", path)
  if ActiveSupport::Dependencies.autoload_paths.include?(path)
    yield
  else
    begin
      ActiveSupport::Dependencies.autoload_paths << path
      yield
    ensure
      ActiveSupport::Dependencies.autoload_paths.reject! {|p| p == path}
      ActiveSupport::Dependencies.clear
    end
  end
end
