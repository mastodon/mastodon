# frozen_string_literal: true

class RequestApprovalService < BaseService
  def call(user)
    return true if user.id.nil?

    if Setting.require_approval
      User.admins.each do |admin|
        UserMailer.new_user_waiting_for_approval(admin, user).deliver_later
      end
    else
      user.approve!
    end
  end
end
