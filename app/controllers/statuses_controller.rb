# frozen_string_literal: true

class StatusesController < ApplicationController
  include WebAppControllerConcern
  include SignatureAuthentication
  include Authorization
  include AccountOwnedConcern

  vary_by -> { public_fetch_mode? ? 'Accept, Accept-Language, Cookie' : 'Accept, Accept-Language, Cookie, Signature' }

  before_action :require_account_signature!, only: [:show, :activity], if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_status
  before_action :set_instance_presenter
  before_action :redirect_to_original, only: :show
  before_action :set_body_classes, only: :embed

  after_action :set_link_headers

  skip_around_action :set_locale, if: -> { request.format == :json }
  skip_before_action :require_functional!, only: [:show, :embed], unless: :whitelist_mode?

  content_security_policy only: :embed do |policy|
    policy.frame_ancestors(false)
  end

  def show
    respond_to do |format|
      format.html do
        expires_in 10.seconds, public: true if current_account.nil?
      end

      format.json do
        expires_in 3.minutes, public: true if @status.distributable? && public_fetch_mode?
        render_with_cache json: @status, content_type: 'application/activity+json', serializer: ActivityPub::NoteSerializer, adapter: ActivityPub::Adapter
      end
    end
  end

  def activity
    expires_in 3.minutes, public: @status.distributable? && public_fetch_mode?
    render_with_cache json: ActivityPub::ActivityPresenter.from_status(@status), content_type: 'application/activity+json', serializer: ActivityPub::ActivitySerializer, adapter: ActivityPub::Adapter
  end

  def embed
    use_pack 'embed'
    return not_found if @status.hidden? || @status.reblog?

    expires_in 180, public: true
    response.headers.delete('X-Frame-Options')

    render layout: 'embedded'
  end

  private

  def set_body_classes
    @body_classes = 'with-modals'
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new([[ActivityPub::TagManager.instance.uri_for(@status), [%w(rel alternate), %w(type application/activity+json)]]])
  end

  def set_status
    @status = @account.statuses.find(params[:id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def redirect_to_original
    redirect_to(ActivityPub::TagManager.instance.url_for(@status.reblog), allow_other_host: true) if @status.reblog?
  end
end
