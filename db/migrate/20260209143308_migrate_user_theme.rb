# frozen_string_literal: true

class MigrateUserTheme < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class User < ApplicationRecord; end

  def up
    User.where.not(settings: nil).find_each do |user|
      settings = Oj.load(user.attributes_before_type_cast['settings'])
      next if settings.nil? || settings['theme'].blank? || %w(system default mastodon-light contrast).exclude?(settings['theme'])

      case settings['theme']
      when 'default'
        settings['web.color_scheme'] = 'dark'
        settings['web.contrast'] = 'auto'
      when 'contrast'
        settings['web.color_scheme'] = 'dark'
        settings['web.contrast'] = 'high'
      when 'mastodon-light'
        settings['web.color_scheme'] = 'light'
        settings['web.contrast'] = 'auto'
      end

      settings['theme'] = 'default'

      user.update_column('settings', Oj.dump(settings))
    end
  end
end
