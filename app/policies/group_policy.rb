# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def show?
    true
  end

  def show_posts?
    true # TODO: add support for private groups?
  end

  def post?
    member?
  end

  def manage_requests?
    group_staff?
  end

  def delete_posts?
    group_staff?
  end

  def manage_blocks?
    group_staff?
  end

  private

  def member?
    record.members.where(id: current_account&.id).exists?
  end

  def group_staff?
    record.memberships.where(account_id: current_account&.id, role: [:moderator, :admin]).exists?
  end
end
