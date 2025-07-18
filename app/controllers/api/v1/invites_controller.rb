# frozen_string_literal: true

class Api::V1::InvitesController < Api::BaseController
  include RegistrationHelper

  skip_before_action :require_authenticated_user!
  skip_around_action :set_locale

  before_action :set_invite
  before_action :check_valid_usage!
  before_action :check_enabled_registrations!

  # Override `current_user` to avoid reading session cookies
  def current_user; end

  def show
    render json: { invite_code: params[:invite_code], instance_api_url: api_v2_instance_url }, status: 200
  end

  private

  def set_invite
    @invite = Invite.find_by!(code: params[:invite_code])
  end

  def check_valid_usage!
    render json: { error: I18n.t('invites.invalid') }, status: 401 unless @invite.valid_for_use?
  end

  def check_enabled_registrations!
    raise Mastodon::NotPermittedError unless allowed_registration?(request.remote_ip, @invite)
  end
end
