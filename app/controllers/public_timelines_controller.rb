# frozen_string_literal: true

class PublicTimelinesController < ApplicationController
  layout 'public'

  before_action :check_enabled
  before_action :set_body_classes
  before_action :set_instance_presenter

  def show
    respond_to do |format|
      format.html do
        @initial_state_json = ActiveModelSerializers::SerializableResource.new(
          InitialStatePresenter.new(settings: { known_fediverse: Setting.show_known_fediverse_at_about_page }, token: current_session&.token),
          serializer: InitialStateSerializer
        ).to_json
      end
    end
  end

  private

  def check_enabled
    raise ActiveRecord::RecordNotFound unless Setting.timeline_preview
  end

  def set_body_classes
    @body_classes = 'with-modals'
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
