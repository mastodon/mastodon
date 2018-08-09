# frozen_string_literal: true
# == Schema Information
#
# Table name: account_pins
#
#  id                :bigint(8)        not null, primary key
#  account_id        :bigint(8)
#  target_account_id :bigint(8)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AccountPin < ApplicationRecord
  include RelationshipCacheable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validate :validate_follow_relationship

  private

  def validate_follow_relationship
    errors.add(:base, I18n.t('accounts.pin_errors.following')) unless account.following?(target_account)
  end
end
