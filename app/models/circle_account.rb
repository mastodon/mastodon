# frozen_string_literal: true

# == Schema Information
#
# Table name: circle_accounts
#
#  id         :bigint(8)        not null, primary key
#  circle_id  :bigint(8)        not null
#  account_id :bigint(8)        not null
#  follow_id  :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CircleAccount < ApplicationRecord
  belongs_to :circle
  belongs_to :account
  belongs_to :follow, optional: true

  validates :account_id, uniqueness: { scope: :circle_id }

  before_validation :set_follow

  private

  def set_follow
    self.follow = Follow.find_by!(target_account_id: circle.account_id, account_id: account.id)
  end
end
