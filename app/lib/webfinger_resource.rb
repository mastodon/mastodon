# frozen_string_literal: true

class WebfingerResource
  attr_reader :resource

  class InvalidRequest < StandardError; end

  def initialize(resource)
    @resource = resource
  end

  def account
    case resource
    when %r{\A(https?://)?#{instance_actor_regexp}/?\Z}
      Account.representative
    when /\Ahttps?/i
      account_from_url
    when /@/
      account_from_acct
    else
      raise InvalidRequest
    end
  end

  private

  def instance_actor_regexp
    hosts = [Rails.configuration.x.local_domain, Rails.configuration.x.web_domain]
    hosts.concat(Rails.configuration.x.alternate_domains) if Rails.configuration.x.alternate_domains.present?

    Regexp.union(hosts)
  end

  def account_from_url
    if account_show_page?
      path_params.key?(:username) ? Account.find_local!(path_params[:username]) : Account.local.find(path_params[:id])
    elsif instance_actor_page?
      Account.representative
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def instance_actor_page?
    path_params[:controller] == 'instance_actors'
  end

  def account_show_page?
    path_params[:controller] == 'accounts' && path_params[:action] == 'show'
  end

  def path_params
    Rails.application.routes.recognize_path(resource)
  end

  def account_from_acct
    raise ActiveRecord::RecordNotFound unless domain_matches_local?

    username = local_username
    return Account.representative if username == Rails.configuration.x.local_domain || username == Rails.configuration.x.web_domain

    Account.find_local!(username)
  end

  def split_acct
    resource_without_acct_string.split('@')
  end

  def resource_without_acct_string
    resource.delete_prefix('acct:')
  end

  def local_username
    split_acct.first
  end

  def local_domain
    split_acct.last
  end

  def domain_matches_local?
    TagManager.instance.local_domain?(local_domain) || TagManager.instance.web_domain?(local_domain) || Rails.configuration.x.alternate_domains.include?(local_domain)
  end
end
