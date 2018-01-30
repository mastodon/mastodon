# frozen_string_literal: true

def render_static_page(dest)
  I18n.with_locale(ENV['DEFAULT_LOCALE'] || I18n.default_locale) do
    File.write(dest, yield)
  end
end

namespace :assets do
  desc 'Generate static pages'
  task generate_static_pages: :environment do
    class StaticController < ApplicationController
      def current_user
        nil
      end
    end

    render_static_page Rails.root.join('public', 'assets', '500.html') do
      StaticController.render 'errors/500', layout: 'error'
    end
  end
end

if Rake::Task.task_defined?('assets:precompile')
  Rake::Task['assets:precompile'].enhance do
    Webpacker.manifest.refresh
    Rake::Task['assets:generate_static_pages'].invoke
  end
end
