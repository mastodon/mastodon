# frozen_string_literal: true

require 'singleton'

class TagManager
  include Singleton
  include RoutingHelper

  def web_domain?(domain)
    domain.nil? || domain.gsub(/[\/]/, '').casecmp(Rails.configuration.x.web_domain).zero?
  end

  def local_domain?(domain)
    domain.nil? || domain.gsub(/[\/]/, '').casecmp(Rails.configuration.x.local_domain).zero?
  end

  def normalize_domain(domain)
    return if domain.nil?

    uri = Addressable::URI.new
    uri.host = domain.gsub(/[\/]/, '')
    uri.normalized_host
  end

  def same_acct?(canonical, needle)
    return true if canonical.casecmp(needle).zero?
    username, domain = needle.split('@')
    local_domain?(domain) && canonical.casecmp(username).zero?
  end

  def local_url?(url)
    uri    = Addressable::URI.parse(url).normalize
    domain = uri.host + (uri.port ? ":#{uri.port}" : '')
    TagManager.instance.web_domain?(domain)
  end

  def url_for(target)
    return target.url if target.respond_to?(:local?) && !target.local?

    case target.object_type
    when :person
      short_account_url(target)
    when :note, :comment, :activity
      short_account_status_url(target.account, target)
    end
  end

  def path_to_resource!(path, klass = nil)
    recognized_params = Rails.application.routes.recognize_path(path)

    raise Mastodon::NotFound unless recognized_params[:action] == 'show'

    if recognized_params[:controller] == 'stream_entries'
      raise Mastodon::NotFound unless klass.nil? || klass == Status
      StreamEntry.find_by!(id: recognized_params[:id])&.status
    elsif recognized_params[:controller] == 'statuses'
      raise Mastodon::NotFound unless klass.nil? || klass == Status
      Status.find_by!(id: recognized_params[:id])
    elsif recognized_params[:controller] == 'accounts'
      raise Mastodon::NotFound unless klass.nil? || klass == Account
      Account.find_local!(recognized_params[:username])
    else
      raise Mastodon::NotFound
    end
  end

  def path_to_resource(path, klass = nil)
    path_to_resource! path, klass
  rescue ActiveRecord::RecordNotFound, Mastodon::NotFound
    nil
  end

  def url_to_resource!(url, klass = nil)
    raise Mastodon::NotFound unless local_url? url
    path_to_resource! url, klass
  end

  def url_to_resource(url, klass = nil)
    local_url?(url) ? path_to_resource(url, klass) : nil
  end
end
