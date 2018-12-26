# frozen_string_literal: true

class StatusPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    if direct?
      owned? || record.mentions.where(account: current_account).exists?
    elsif private?
      owned? || current_account&.following?(author) || record.mentions.where(account: current_account).exists?
    else
      current_account.nil? || !author.blocking?(current_account)
    end
  end

  def reblog?
    !direct? && !private? && show?
  end

  def destroy?
    staff? || owned?
  end

  alias unreblog? destroy?

  def update?
    staff?
  end

  private

  def direct?
    record.direct_visibility?
  end

  def owned?
    author.id == current_account&.id
  end

  def private?
    record.private_visibility?
  end

  def author
    record.account
  end
end
