# frozen_string_literal: true

class REST::InstanceSerializer < ActiveModel::Serializer
  attributes :uri, :title, :description, :email,
             :version, :urls

  def uri
    Rails.configuration.x.local_domain
  end

  def title
    Setting.site_title
  end

  def description
    Setting.site_description
  end

  def email
    Setting.site_contact_email
  end

  def version
    Mastodon::Version.to_s
  end

  def urls
    { streaming_api: Rails.configuration.x.streaming_api_base_url }
  end
end
