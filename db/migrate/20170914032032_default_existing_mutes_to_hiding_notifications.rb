# frozen_string_literal: true

# This migration is glitch-soc-only because mutes were originally developed in
# glitch-soc and the default value changed when submitting the code upstream.

# This migration originally changed existing values to `true`, but this has
# been dropped as to not cause issues when migrating from upstream.

class DefaultExistingMutesToHidingNotifications < ActiveRecord::Migration[5.1]
  def up
    change_column_default :mutes, :hide_notifications, from: false, to: true
  end
end
