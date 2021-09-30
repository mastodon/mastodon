# frozen_string_literal: true

class PublicTimelinesController < ApplicationController
  include WebAppControllerConcern

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!

  def show; end

  private

  def require_enabled!
    not_found unless Setting.timeline_preview
  end
end
