# frozen_string_literal: true

if Rake::Task.task_defined?('spec:system')
  namespace :spec do
    task :enable_system_specs do # rubocop:disable Rails/RakeEnvironment
      ENV['RUN_SYSTEM_SPECS'] = 'true'
    end
  end

  Rake::Task['spec:system'].enhance ['spec:enable_system_specs']
end

if Rake::Task.task_defined?('spec:search')
  namespace :spec do
    task :enable_search_specs do # rubocop:disable Rails/RakeEnvironment
      ENV['RUN_SEARCH_SPECS'] = 'true'
    end
  end

  Rake::Task['spec:search'].enhance ['spec:enable_search_specs']
end
