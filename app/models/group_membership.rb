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
  include Paginable
  include GroupRelationshipCacheable

  belongs_to :group
  belongs_to :account

  enum role: {
    user:      0,
    moderator: 1_000,
    admin:     2_000,
  }, _suffix: :role

  scope :recent, -> { reorder(id: :desc) }

  validate :validate_remote_role

  after_create :increment_cache_counters
  after_destroy :decrement_cache_counters

  private

  def increment_cache_counters
    group&.increment_count!(:members_count)
  end

  def decrement_cache_counters
    group&.decrement_count!(:members_count)
  end

  def validate_remote_role
    errors.add(:role, I18n.t('groups.errors.unsupported_remote_role')) if group.local? && !account.local? && !user_role?
  end
end
