# frozen_string_literal: true

class PublicTimelinesController < ApplicationController
  before_action :set_pack
  layout 'public'

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!
  before_action :set_body_classes
  before_action :set_instance_presenter

  def show; end

  private

  def require_enabled!
    not_found unless Setting.timeline_preview
  end

  def set_body_classes
    @body_classes = 'with-modals'
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_pack
    use_pack 'about'
  end
end
