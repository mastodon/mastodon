PROJECT_ROOT     = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
APP_NAME         = 'testapp'.freeze
BUNDLE_ENV_VARS = %w(RUBYOPT BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE)
ORIGINAL_BUNDLE_VARS = Hash[ENV.select{ |key,value| BUNDLE_ENV_VARS.include?(key) }]

ENV['RAILS_ENV'] = 'test'

Before do
  gemfile = ENV['BUNDLE_GEMFILE'].to_s
  ENV['BUNDLE_GEMFILE'] = File.join(Dir.pwd, gemfile) unless gemfile.start_with?(Dir.pwd)
  @framework_version = nil
end

After do
  ORIGINAL_BUNDLE_VARS.each_pair do |key, value|
    ENV[key] = value
  end
end

When /^I reset Bundler environment variable$/ do
  BUNDLE_ENV_VARS.each do |key|
    ENV[key] = nil
  end
end

module RailsCommandHelpers
  def framework_version?(version_string)
    framework_version =~ /^#{version_string}/
  end

  def framework_version
    @framework_version ||= `rails -v`[/^Rails (.+)$/, 1]
  end

  def framework_major_version
    framework_version.split(".").first.to_i
  end
end
World(RailsCommandHelpers)
