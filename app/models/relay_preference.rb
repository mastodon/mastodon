# frozen_string_literal: true

# == Schema Information
#
# Table name: relay_preferences
#
#  id         :bigint(8)        not null, primary key
#  enabled    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#  relay_id   :bigint(8)        not null
#

class RelayPreference < ApplicationRecord
  belongs_to :account
  belongs_to :relay
end
