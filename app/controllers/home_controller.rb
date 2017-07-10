# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_initial_state_json

  def index
    @body_classes = 'app-body'
  end

  private

  def authenticate_user!
    redirect_to(single_user_mode? ? account_path(Account.first) : about_path) unless user_signed_in?
  end

  def set_initial_state_json
    state = InitialStatePresenter.new(settings: Web::Setting.find_by(user: current_user)&.data || {},
                                      current_account: current_account,
                                      token: current_session.token,
                                      admin: Account.find_local(Setting.site_contact_username))

    serializable_resource = ActiveModelSerializers::SerializableResource.new(state, serializer: InitialStateSerializer)
    @initial_state_json   = serializable_resource.to_json
  end
end
