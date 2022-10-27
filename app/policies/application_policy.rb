# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :current_account, :record

  def initialize(current_account, record)
    @current_account = current_account
    @record          = record
  end

  private

  def current_user
    current_account&.user
  end

  def user_signed_in?
    !current_user.nil?
  end

  def role
    current_user&.role || UserRole.nobody
  end
end
