# frozen_string_literal: true

class AccountPin < ApplicationRecord
  include Paginable
  include RelationshipCacheable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  validate :validate_follow_relationship

  private

  def validate_follow_relationship
    errors.add(:base, I18n.t('accounts.pin_errors.following')) unless account.following?(target_account)
  end
end
