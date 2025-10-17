# frozen_string_literal: true

# See also: USERNAME_RE in the Account class

class UniqueUsernameValidator < ActiveModel::Validator
  def validate(account)
    return if account.username.blank?

    scope = Account.with_username(account.username).with_domain(account.domain)
    scope = scope.excluding(account) if account.persisted?

    account.errors.add(:username, :taken) if scope.exists?
  end
end
