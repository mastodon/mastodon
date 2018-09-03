# frozen_string_literal: true

class AboutController < ApplicationController
  before_action :set_body_classes
  before_action :set_instance_presenter, only: [:show, :more, :terms]

  def show
    serializable_resource = ActiveModelSerializers::SerializableResource.new(InitialStatePresenter.new(initial_state_params), serializer: InitialStateSerializer)
    @initial_state_json   = serializable_resource.to_json
  end

  def more
    render layout: 'public'
  end

  def terms
    render layout: 'public'
  end

  private

  def new_user
    User.new.tap(&:build_account)
  end

  helper_method :new_user

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_body_classes
    @body_classes = 'with-modals'
  end

  def initial_state_params
    {
      settings: { known_fediverse: Setting.show_known_fediverse_at_about_page },
      token: current_session&.token,
    }
  end
end
