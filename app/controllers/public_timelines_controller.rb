# frozen_string_literal: true

class PublicTimelinesController < ApplicationController
  before_action :set_pack
  layout 'public'

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :require_enabled!
  before_action :set_body_classes
  before_action :set_instance_presenter

  def show
    @initial_state_json = ActiveModelSerializers::SerializableResource.new(
      InitialStatePresenter.new(settings: { known_fediverse: Setting.show_known_fediverse_at_about_page }, token: current_session&.token),
      serializer: InitialStateSerializer
    ).to_json
  end

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
