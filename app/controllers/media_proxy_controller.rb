# frozen_string_literal: true

class MediaProxyController < ApplicationController
  include RoutingHelper

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
    @media_attachment.file_remote_url = @media_attachment.remote_url
    @media_attachment.created_at      = Time.now.utc
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
    DomainBlock.find_by(domain: @media_attachment.account.domain)&.reject_media?
  end
end
