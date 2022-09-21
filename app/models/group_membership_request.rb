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
  belongs_to :group
  belongs_to :account
end
