# frozen_string_literal: true

class FollowRequestPresenter < ActiveModelSerializers::Model
  attributes :account, :target_account, :uri

  def local?
    false # Force uri_for to use uri attribute
  end
end
