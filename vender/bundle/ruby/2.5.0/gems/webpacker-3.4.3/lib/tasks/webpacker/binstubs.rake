binstubs_template_path = File.expand_path("../../install/binstubs.rb", __dir__).freeze

namespace :webpacker do
  desc "Installs Webpacker binstubs in this application"
  task binstubs: [:check_node, :check_yarn] do
    if Rails::VERSION::MAJOR >= 5
      exec "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{binstubs_template_path}"
    else
      exec "#{RbConfig.ruby} ./bin/rake rails:template LOCATION=#{binstubs_template_path}"
    end
  end
end
