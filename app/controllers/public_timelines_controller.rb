# frozen_string_literal: true

class PublicTimelinesController < ApplicationController
  include WebAppControllerConcern

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!

  def show
    expires_in 0, public: true if current_account.nil?
  end

  private

  def require_enabled!
    not_found unless user_signed_in? || Setting.timeline_preview
  end
end
