# frozen_string_literal: true
# == Schema Information
#
# Table name: list_accounts
#
#  id         :bigint(8)        not null, primary key
#  list_id    :bigint(8)        not null
#  account_id :bigint(8)        not null
#  follow_id  :bigint(8)
#

class ListAccount < ApplicationRecord
  belongs_to :list
  belongs_to :account
  belongs_to :follow, optional: true

  validates :account_id, uniqueness: { scope: :list_id }

  before_validation :set_follow

  private

  def set_follow
    self.follow = Follow.find_by!(account_id: list.account_id, target_account_id: account.id) unless list.account_id == account.id
  end
end
