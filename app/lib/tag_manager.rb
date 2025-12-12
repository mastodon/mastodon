# frozen_string_literal: true

require 'singleton'

class TagManager
  include Singleton
  include RoutingHelper

  def web_domain?(domain)
    domain.nil? || domain.delete_suffix('/').casecmp(Rails.configuration.x.web_domain).zero?
  end

  def local_domain?(domain)
    domain.nil? || domain.delete_suffix('/').casecmp(Rails.configuration.x.local_domain).zero?
  end

  def normalize_domain(domain)
    return if domain.nil?

    uri = Addressable::URI.new
    uri.host = domain.strip.delete_suffix('/')
    uri.normalized_host
  end

  def local_url?(url)
    uri    = Addressable::URI.parse(url).normalize
    return false unless uri.host

    domain = uri.host + (uri.port ? ":#{uri.port}" : '')

    TagManager.instance.web_domain?(domain)
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    false
  end
end
