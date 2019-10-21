# frozen_string_literal: true

class InitialStatePresenter < ActiveModelSerializers::Model
  attributes :settings, :push_subscription, :token,
             :current_account, :admin, :text,
             :tanker_identity, :email, :tanker_app_id
end
