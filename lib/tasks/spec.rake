# frozen_string_literal: true

namespace :spec do
  task :enable_system_specs do # rubocop:disable Rails/RakeEnvironment
    ENV['RUN_SYSTEM_SPECS'] = 'true'
  end
end

Rake::Task['spec:system'].enhance ['spec:enable_system_specs']
