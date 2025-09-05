# frozen_string_literal: true

class FillDefaultQuotePolicySetting < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class User < ApplicationRecord; end

  def up
    User.where.not(settings: nil).find_each do |user|
      settings = Oj.load(user.attributes_before_type_cast['settings'])

      # We set default quote policy based on privacy so skip users where `default_privacy` isn't set
      next if settings.nil? || settings['default_privacy'].nil?

      # Only override existing `default_quote_policy` if it's a forbidden value
      if settings['default_privacy'] == 'private' && settings['default_quote_policy'] != 'nobody'
        user.update_column('settings', Oj.dump(settings.merge('default_quote_policy' => 'nobody')))
      elsif settings['default_quote_policy'].nil? && settings['default_privacy'] == 'unlisted'
        user.update_column('settings', Oj.dump(settings.merge('default_quote_policy' => 'followers')))
      end
    end
  end
end
