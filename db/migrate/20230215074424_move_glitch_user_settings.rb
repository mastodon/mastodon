# frozen_string_literal: true

class MoveGlitchUserSettings < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class User < ApplicationRecord; end

  MAPPING = {
    favourite_modal: 'web.favourite_modal',
    system_emoji_font: 'web.use_system_emoji_font',
    hide_followers_count: 'hide_followers_count',
    default_content_type: 'default_content_type',
    flavour: 'flavour',
    skin: 'skin',
    notification_emails: {
      trending_link: 'notification_emails.link_trends',
      trending_status: 'notification_emails.status_trends',
    }.freeze,
  }.freeze

  class LegacySetting < ApplicationRecord
    self.table_name = 'settings'

    def var
      self[:var]&.to_sym
    end

    def value
      YAML.safe_load(self[:value], permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol]) if self[:value].present?
    end
  end

  def up
    User.find_in_batches do |users|
      previous_settings_for_batch = LegacySetting.where(thing_type: 'User', thing_id: users.map(&:id)).group_by(&:thing_id)

      users.each do |user|
        previous_settings = previous_settings_for_batch[user.id]&.index_by(&:var) || {}
        user_settings = Oj.load(user.settings || '{}')
        user_settings.delete('theme')

        MAPPING.each do |legacy_key, new_key|
          value = previous_settings[legacy_key]&.value

          next if value.nil?

          if value.is_a?(Hash)
            value.each do |nested_key, nested_value|
              user_settings[MAPPING[legacy_key][nested_key.to_sym]] = nested_value
            end
          else
            user_settings[new_key] = value
          end
        end

        user.update_column('settings', Oj.dump(user_settings)) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  def down; end
end
