# frozen_string_literal: true

# == Schema Information
#
# Table name: moderation_subscriptions
#
#  id                     :bigint(8)        not null, primary key
#  apply_automatically    :boolean          default(FALSE), not null
#  last_synced_at         :datetime
#  list_action            :integer
#  name                   :string
#  preserve_relationships :boolean          default(TRUE), not null
#  priority               :integer
#  retract_automatically  :boolean          default(TRUE), not null
#  type                   :integer          not null
#  url                    :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ModerationSubscription < ApplicationRecord
  self.inheritance_column = nil

  enum :type, {
    csv_list: 0,
  }

  enum :list_action, {
    accept: 0,
    reject: 1,
  }, suffix: :action
end
