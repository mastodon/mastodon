# frozen_string_literal: true

class FillDefaultQuotePolicySetting < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class User < ApplicationRecord; end

  def up
    User.where.not(settings: nil).find_each do |user|
      settings = Oj.load(user.attributes_before_type_cast['settings'])
      next if settings.nil?

      should_update_settings = false

      if settings['notification_emails.quote'].blank? && settings['notification_emails.reblog'] == false && settings['notification_emails.mention'] == false
        settings['notification_emails.quote'] = false
        should_update_settings = true
      end

      if settings['default_privacy'] == 'private' && settings['default_quote_policy'] != 'nobody'
        settings['default_quote_policy'] = 'nobody'
        should_update_settings = true
      elsif settings['default_quote_policy'].nil? && settings['default_privacy'] == 'unlisted'
        settings['default_quote_policy'] = 'followers'
        should_update_settings = true
      end

      user.update_column('settings', Oj.dump(settings)) if should_update_settings
    end
  end
end
