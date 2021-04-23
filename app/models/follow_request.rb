# frozen_string_literal: true
# == Schema Information
#
# Table name: follow_requests
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint(8)        not null
#  target_account_id :bigint(8)        not null
#  show_reblogs      :boolean          default(TRUE), not null
#  uri               :string
#  notify            :boolean          default(FALSE), not null
#

class FollowRequest < ApplicationRecord
  include Paginable
  include RelationshipCacheable
  include RateLimitable
  include FollowLimitable

  rate_limit by: :account, family: :follows

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }

  def authorize!
    account.follow!(target_account, reblogs: show_reblogs, notify: notify, uri: uri, bypass_limit: true)
    MergeWorker.perform_async(target_account.id, account.id) if account.local?
    destroy!
  end

  alias reject! destroy!

  def local?
    false # Force uri_for to use uri attribute
  end

  before_validation :set_uri, only: :create

  private

  def set_uri
    self.uri = ActivityPub::TagManager.instance.generate_uri_for(self) if uri.nil?
  end
end
