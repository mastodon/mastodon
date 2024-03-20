# frozen_string_literal: true

#
# == Schema Information
#
# Table name: account_relationship_severance_events
#
#  id                              :bigint(8)        not null, primary key
#  account_id                      :bigint(8)        not null
#  relationship_severance_event_id :bigint(8)        not null
#  relationships_count             :integer          default(0), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
class AccountRelationshipSeveranceEvent < ApplicationRecord
  belongs_to :account
  belongs_to :relationship_severance_event

  delegate :severed_relationships,
           :type,
           :target_name,
           :purged,
           :purged?,
           to: :relationship_severance_event,
           prefix: false

  before_create :set_relationships_count!

  private

  def set_relationships_count!
    self.relationships_count = severed_relationships.where(local_account: account).count
  end
end
