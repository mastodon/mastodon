# frozen_string_literal: true

class Admin::BasePolicy < ApplicationPolicy
  def access?
    role.administrator? || role.can?(*UserRole::Flags::CATEGORIES.fetch_values(:moderation, :administration, :devops).flatten)
  end
end
