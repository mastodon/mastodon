# frozen_string_literal: true

class RemoveLegacyUserSettingsData < ActiveRecord::Migration[7.2]
  def up
    connection.execute(<<~SQL.squish)
      DELETE FROM settings
      WHERE
        thing_type IS NOT NULL
        AND thing_id IS NOT NULL
    SQL

    # When running these migrations on mastodon.social, we saw 'notification_emails'
    # and 'interactions' records that were not associated to a user and caused a
    # migration issue.
    # While I have not been able to pinpoint the exact cause of the issue, it is likely
    # related to the settings system changes made in b11fdc3ae3f90731c01149a5a36dc64e065d4ea2.
    # So, delete a few user settings that should already have been deleted.
    connection.execute(<<~SQL.squish)
      DELETE FROM settings
      WHERE var IN (
        'notification_emails', 'interactions', 'boost_modal', 'auto_play_gif',
        'delete_modal', 'system_font_ui', 'default_sensitive', 'unfollow_modal',
        'reduce_motion', 'display_sensitive_media', 'hide_network', 'expand_spoilers',
        'display_media', 'aggregate_reblogs', 'show_application', 'advanced_layout',
        'use_blurhash', 'use_pending_items')
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
