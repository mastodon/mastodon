# frozen_string_literal: true
# == Schema Information
#
# Table name: list_accounts
#
#  id         :integer          not null, primary key
#  list_id    :integer          not null
#  account_id :integer          not null
#  follow_id  :integer          not null
#

class ListAccount < ApplicationRecord
  belongs_to :list
  belongs_to :account
  belongs_to :follow

  validates :account_id, uniqueness: { scope: :list_id }

  before_validation :set_follow

  private

  def set_follow
    self.follow = Follow.find_by(account_id: list.account_id, target_account_id: account.id)
  end
end
