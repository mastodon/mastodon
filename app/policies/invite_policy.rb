# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  def index?
    staff?
  end

  def create?
    min_required_role?
  end

  def destroy?
    owner? || (Setting.min_invite_role == 'admin' ? admin? : staff?)
  end

  private

  def owner?
    record.user_id == current_user&.id
  end

  def min_required_role?
    current_user&.role?(Setting.min_invite_role)
  end
end
