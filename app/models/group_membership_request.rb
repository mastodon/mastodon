# == Schema Information
#
# Table name: group_membership_requests
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  group_id   :bigint(8)        not null
#  uri        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GroupMembershipRequest < ApplicationRecord
  include Paginable
  include GroupRelationshipCacheable

  belongs_to :group
  belongs_to :account

  before_validation :set_uri, only: :create

  def authorize!
    group.memberships.create!(account: account, uri: uri)
    destroy!
  end

  alias reject! destroy!

  def local?
    false # Force uri_for to use uri attribute
  end

  private

  def set_uri
    self.uri = ActivityPub::TagManager.instance.generate_uri_for(self) if uri.nil?
  end
end
