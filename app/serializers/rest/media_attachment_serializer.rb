# frozen_string_literal: true

class REST::MediaAttachmentSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :url, :preview_url,
             :remote_url, :text_url, :meta,
             :description, :blurhash

  def id
    object.id.to_s
  end

  def url
    if object.not_processed?
      nil
    elsif object.needs_redownload?
      media_proxy_url(object.id, :original)
    else
      full_asset_url(object.file.url(:original))
    end
  end

  def remote_url
    object.remote_url.presence
  end

  def preview_url
    if object.needs_redownload?
      media_proxy_url(object.id, :small)
    elsif object.thumbnail.present?
      full_asset_url(object.thumbnail.url(:original))
    elsif object.file.styles.key?(:small)
      full_asset_url(object.file.url(:small))
    end
  end

  def text_url
    object.local? ? medium_url(object) : nil
  end

  def meta
    object.file.meta
  end
end
