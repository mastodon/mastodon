# frozen_string_literal: true

class InitialStatePresenter < ActiveModelSerializers::Model
  attributes :settings, :push_subscription, :token,
             :current_account, :admin, :owner, :text, :visibility,
             :disabled_account, :moved_to_account, :critical_updates_pending

  def role
    current_account&.user_role
  end

  def critical_updates_pending
    role&.can?(:view_devops) && SoftwareUpdate.urgent_pending?
  end
end
