# frozen_string_literal: true

class MediaController < ApplicationController
  include Authorization

  skip_before_action :store_current_location
  skip_before_action :require_functional!, unless: :whitelist_mode?

  before_action :authenticate_user!, if: :whitelist_mode?
  before_action :set_media_attachment
  before_action :verify_permitted_status!
  before_action :check_playable, only: :player
  before_action :allow_iframing, only: :player
  before_action :set_pack, only: :player

  content_security_policy only: :player do |policy|
    policy.frame_ancestors(false)
  end

  def show
    redirect_to @media_attachment.file.url(:original)
  end

  def player
    @body_classes = 'player'
  end

  private

  def set_media_attachment
    id = params[:id] || params[:medium_id]
    return if id.nil?

    scope = MediaAttachment.local.attached
    # If id is 19 characters long, it's a shortcode, otherwise it's an identifier
    @media_attachment = id.size == 19 ? scope.find_by!(shortcode: id) : scope.find(id)
  end

  def verify_permitted_status!
    authorize @media_attachment.status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def check_playable
    not_found unless @media_attachment.larger_media_format?
  end

  def allow_iframing
    response.headers['X-Frame-Options'] = 'ALLOWALL'
  end

  def set_pack
    use_pack 'public'
  end
end
