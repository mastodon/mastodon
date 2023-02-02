# frozen_string_literal: true

class CustomEmojiPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_custom_emojis)
  end

  def create?
    role.can?(:manage_custom_emojis)
  end

  def update?
    role.can?(:manage_custom_emojis)
  end

  def copy?
    role.can?(:manage_custom_emojis)
  end

  def enable?
    role.can?(:manage_custom_emojis)
  end

  def disable?
    role.can?(:manage_custom_emojis)
  end

  def destroy?
    role.can?(:manage_custom_emojis)
  end
end
