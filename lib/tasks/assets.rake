# frozen_string_literal: true

namespace :assets do
  desc 'Generate 500.html'
  task :generate_500 do
    I18n.with_locale(ENV['DEFAULT_LOCALE'] || I18n.default_locale) do
      html = ApplicationController.render('errors/500', layout: 'error')
      File.write(Rails.root.join('public', '500.html'), html)
    end
  end
end

if Rake::Task.task_defined?('assets:precompile')
  Rake::Task['assets:precompile'].enhance do
    Webpacker::Manifest.load
    Rake::Task['assets:generate_500'].invoke
  end
end
