# frozen_string_literal: true

# == Schema Information
#
# Table name: blocks
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  uri               :string
#

class Block < ApplicationRecord
  include Paginable
  include RelationshipCacheable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validates :account_id, uniqueness: { scope: :target_account_id }

  def local?
    false # Force uri_for to use uri attribute
  end

  after_commit :remove_blocking_cache
  before_validation :set_uri, only: :create

  private

  def remove_blocking_cache
    Rails.cache.delete("exclude_account_ids_for:#{account_id}")
    Rails.cache.delete("exclude_account_ids_for:#{target_account_id}")
  end

  def set_uri
    self.uri = ActivityPub::TagManager.instance.generate_uri_for(self) if uri.nil?
  end
end
