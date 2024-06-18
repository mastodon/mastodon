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
  after_commit :add_list_account, on: :create
  after_commit :remove_list_account, on: :destroy

  private

  def add_list_account
    circle.list.list_accounts.create!(account_id: account_id)
  end

  def remove_list_account
    circle.list.list_accounts.find_by(account_id: account_id).destroy!
  end

  def set_follow
    self.follow = Follow.find_by!(target_account_id: circle.account_id, account_id: account.id)
  end
end
