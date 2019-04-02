# frozen_string_literal: true

class InstanceActorPresenter < ActiveModelSerializers::Model
  def id
    'instance-actor'
  end

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
    Account.local.first.public_key
  end

  def keypair
    Account.local.first.keypair
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
