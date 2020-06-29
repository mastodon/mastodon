# frozen_string_literal: true

class MediaProxyController < ApplicationController
  include RoutingHelper

  skip_before_action :store_current_location
  skip_before_action :require_functional!

  before_action :authenticate_user!, if: :whitelist_mode?

  rescue_from ActiveRecord::RecordInvalid, with: :not_found
  rescue_from Mastodon::UnexpectedResponseError, with: :not_found
  rescue_from HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError, with: :internal_server_error

  def show
    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        @media_attachment = MediaAttachment.remote.find(params[:id])
        redownload! if @media_attachment.needs_redownload? && !reject_media?
      else
        raise Mastodon::RaceConditionError
      end
    end

    redirect_to full_asset_url(@media_attachment.file.url(version))
  end

  private

  def redownload!
    @media_attachment.download_file!
    @media_attachment.created_at = Time.now.utc
    @media_attachment.save!
  end

  def version
    if request.path.ends_with?('/small')
      :small
    else
      :original
    end
  end

  def lock_options
    { redis: Redis.current, key: "media_download:#{params[:id]}" }
  end

  def reject_media?
    DomainBlock.reject_media?(@media_attachment.account.domain)
  end
end
