# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def post?
    record.members.where(id: current_account&.id).exists?
  end
end
