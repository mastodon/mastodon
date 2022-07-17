# frozen_string_literal: true

class InitialStatePresenter < ActiveModelSerializers::Model
  attributes :settings, :push_subscription, :token,
             :current_account, :admin, :text, :visibility

  def role
    current_account&.user_role
  end
end
