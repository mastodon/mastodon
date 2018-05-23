require 'bundler'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

Rake::TestTask.new
task :default => [:test]

task :test => :set_frozen_string_literal_option
task :set_frozen_string_literal_option do
  if RUBY_ENGINE == "ruby" && RUBY_VERSION >= "2.3"
    warn "NOTE: Testing support for frozen string literals"
    ENV['RUBYOPT'] ||= ""
    ENV['RUBYOPT'] += " --enable-frozen-string-literal --debug=frozen-string-literal"
  end
end

task :'pull-css-tests' do
  sh 'git subtree pull -P test/css-parsing-tests https://github.com/SimonSapin/css-parsing-tests.git master --squash'
end
