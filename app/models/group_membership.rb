# == Schema Information
#
# Table name: group_memberships
#
#  id         :bigint(8)        not null, primary key
#  account_id :bigint(8)        not null
#  group_id   :bigint(8)        not null
#  role       :integer          default("user"), not null
#  uri        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :account

  enum role: {
    user:      0,
    moderator: 1_000,
    admin:     2_000,
  }, _suffix: :role

  validate :validate_remote_role

  private

  def validate_remote_role
    errors.add(:role, I18n.t('groups.errors.unsupported_remote_role')) if group.local? && !account.local? && !user_role?
  end
end
