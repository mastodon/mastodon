# frozen_string_literal: true

class InitialStatePresenter < ActiveModelSerializers::Model
  attributes :settings, :push_subscription, :token,
             :current_account, :custom_emojis, :admin, :text
end
