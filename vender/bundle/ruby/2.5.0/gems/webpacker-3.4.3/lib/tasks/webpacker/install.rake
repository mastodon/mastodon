install_template_path = File.expand_path("../../install/template.rb", __dir__).freeze

namespace :webpacker do
  desc "Install Webpacker in this application"
  task install: [:check_node, :check_yarn] do
    if Rails::VERSION::MAJOR >= 5
      exec "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{install_template_path}"
    else
      exec "#{RbConfig.ruby} ./bin/rake rails:template LOCATION=#{install_template_path}"
    end
  end
end
