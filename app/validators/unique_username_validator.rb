# frozen_string_literal: true

# See also: USERNAME_RE in the Account class

class UniqueUsernameValidator < ActiveModel::Validator
  def validate(account)
    return if account.username.blank?

    normalized_username = account.username.downcase
    normalized_domain = account.domain&.downcase

    scope = Account.where(Account.arel_table[:username].lower.eq normalized_username).where(Account.arel_table[:domain].lower.eq normalized_domain)
    scope = scope.where.not(id: account.id) if account.persisted?

    account.errors.add(:username, :taken) if scope.exists?
  end
end
