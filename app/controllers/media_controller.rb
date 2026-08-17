# frozen_string_literal: true

class MediaController < ApplicationController
  include Authorization

  skip_before_action :require_functional!, unless: :limited_federation_mode?

  before_action :authenticate_user!, if: :limited_federation_mode?
  before_action :set_media_attachment
  before_action :verify_permitted_status!
  before_action :check_playable, only: :player
  before_action :allow_iframing, only: :player

  content_security_policy only: :player do |policy|
    policy.frame_ancestors(false)
  end

  def show
    redirect_to @media_attachment.file.url(:original)
  end

  def player; end

  private

  def set_media_attachment
    @media_attachment = MediaAttachment.local.attached.identified(params[:id])
  end

  def verify_permitted_status!
    authorize @media_attachment.status, :show?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  end

  def check_playable
    not_found unless @media_attachment.larger_media_format?
  end

  def allow_iframing
    response.headers.delete('X-Frame-Options')
  end
end
