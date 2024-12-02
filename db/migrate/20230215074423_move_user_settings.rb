# frozen_string_literal: true

class MoveUserSettings < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  class User < ApplicationRecord; end

  MAPPING = {
    default_privacy: 'default_privacy',
    default_sensitive: 'web.default_sensitive',
    default_language: 'default_language',
    noindex: 'noindex',
    theme: 'theme',
    trends: 'web.trends',
    unfollow_modal: 'web.unfollow_modal',
    boost_modal: 'web.reblog_modal',
    delete_modal: 'web.delete_modal',
    auto_play_gif: 'web.auto_play',
    display_media: 'web.display_media',
    expand_spoilers: 'web.expand_content_warnings',
    reduce_motion: 'web.reduce_motion',
    disable_swiping: 'web.disable_swiping',
    show_application: 'show_application',
    system_font_ui: 'web.use_system_font',
    aggregate_reblogs: 'aggregate_reblogs',
    advanced_layout: 'web.advanced_layout',
    use_blurhash: 'web.use_blurhash',
    use_pending_items: 'web.use_pending_items',
    crop_images: 'web.crop_images',
    notification_emails: {
      follow: 'notification_emails.follow',
      reblog: 'notification_emails.reblog',
      favourite: 'notification_emails.favourite',
      mention: 'notification_emails.mention',
      follow_request: 'notification_emails.follow_request',
      report: 'notification_emails.report',
      pending_account: 'notification_emails.pending_account',
      trending_tag: 'notification_emails.trends',
      appeal: 'notification_emails.appeal',
    }.freeze,
    always_send_emails: 'always_send_emails',
    interactions: {
      must_be_follower: 'interactions.must_be_follower',
      must_be_following: 'interactions.must_be_following',
      must_be_following_dm: 'interactions.must_be_following_dm',
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
        user_settings     = {}

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

        user.update_column('settings', Oj.dump(user_settings))
      end
    end
  end

  def down; end
end
