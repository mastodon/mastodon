# frozen_string_literal: true

class Admin::BasePolicy < ApplicationPolicy
  def access?
    role.administrator? || role.can?(*UserRole::Flags::CATEGORIES[:moderation]) || role.can?(*UserRole::Flags::CATEGORIES[:administration])
  end
end
