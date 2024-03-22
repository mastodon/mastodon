# frozen_string_literal: true

#
# == Schema Information
#
# Table name: account_relationship_severance_events
#
#  id                              :bigint(8)        not null, primary key
#  account_id                      :bigint(8)        not null
#  relationship_severance_event_id :bigint(8)        not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  followers_count                 :integer          default(0), not null
#  following_count                 :integer          default(0), not null
#
class AccountRelationshipSeveranceEvent < ApplicationRecord
  self.ignored_columns += %w(
    relationships_count
  )

  belongs_to :account
  belongs_to :relationship_severance_event

  has_many :severed_relationships, through: :relationship_severance_event

  delegate :type,
           :target_name,
           :purged,
           :purged?,
           to: :relationship_severance_event,
           prefix: false

  before_create :set_relationships_count!

  private

  def set_relationships_count!
    self.followers_count = severed_relationships.about_local_account(account).passive.count
    self.following_count = severed_relationships.about_local_account(account).active.count
  end
end
