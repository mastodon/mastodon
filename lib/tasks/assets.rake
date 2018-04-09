# frozen_string_literal: true

def render_static_page(action, dest:, **opts)
  html = ApplicationController.render(action, opts)
  File.write(dest, html)
end

namespace :assets do
  desc 'Generate static pages'
  task generate_static_pages: :environment do
    render_static_page 'errors/500', layout: 'error', dest: Rails.root.join('public', 'assets', '500.html')
  end
end

if Rake::Task.task_defined?('assets:precompile')
  Rake::Task['assets:precompile'].enhance do
    Webpacker.manifest.refresh
    Rake::Task['assets:generate_static_pages'].invoke
  end
end
