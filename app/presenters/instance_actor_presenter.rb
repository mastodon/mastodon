# frozen_string_literal: true

class InstanceActorPresenter < ActiveModelSerializers::Model
  attributes :display_name, :username, :summary, :avatar, :header, :locked, :public_key

  def object_type
    :application
  end

  def display_name
    Rails.configuration.x.local_domain
  end

  def username
    Rails.configuration.x.local_domain
  end

  def summary
    "Virtual ActivityPub Actor for Mastodon instance #{Rails.configuration.x.local_domain}"
  end

  def avatar
    nil
  end

  def header
    return @header if defined?(@header)
    thumbnail = Rails.cache.fetch('site_uploads/thumbnail') { SiteUpload.find_by(var: 'thumbnail') }
    @header = thumbnail&.file
    @header
  end

  def public_key
    nil # TODO
  end

  def locked
    true
  end

  def avatar?
    avatar.present?
  end

  def header?
    header.present?
  end
end
