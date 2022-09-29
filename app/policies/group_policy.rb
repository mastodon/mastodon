# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    role.can?(:manage_users)
  end

  def create?
    role.can?(:create_groups)
  end

  def update?
    group_admin?
  end

  def show?
    true
  end

  def show_posts?
    true # TODO: add support for private groups?
  end

  def suspend?
    role.can?(:manage_users, :manage_reports)
  end

  def unsuspend?
    role.can?(:manage_users, :manage_reports)
  end

  def destroy?
    group_admin? || (record.suspended_temporarily? && role.can?(:delete_user_data))
  end

  def remove_avatar?
    role.can?(:manage_users, :manage_reports)
  end

  def remove_header?
    role.can?(:manage_users, :manage_reports)
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

  def group_admin?
    record.memberships.where(account_id: current_account&.id, role: :admin).exists?
  end

  def group_staff?
    record.memberships.where(account_id: current_account&.id, role: [:moderator, :admin]).exists?
  end
end
