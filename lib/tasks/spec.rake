# frozen_string_literal: true

if Rake::Task.task_defined?('spec:system')
  namespace :spec do
    task :enable_system_specs do # rubocop:disable Rails/RakeEnvironment
      ENV['LOCAL_DOMAIN'] = 'localhost:3000'
      ENV['LOCAL_HTTPS'] = 'false'
      ENV['RUN_SYSTEM_SPECS'] = 'true'
      ENV['WEB_DOMAIN'] = 'localhost:3000'
    end
  end

  Rake::Task['spec:system'].enhance ['spec:enable_system_specs']
end
