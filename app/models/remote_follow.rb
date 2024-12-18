# frozen_string_literal: true

class RemoteFollow
  include ActiveModel::Validations
  include RoutingHelper

  attr_accessor :acct, :addressable_template

  validates :acct, presence: true, domain: { acct: true }

  def initialize(attrs = {})
    @acct = normalize_acct(attrs[:acct])
  end

  def valid?
    return false unless super

    fetch_template!

    errors.empty?
  end

  def subscribe_address_for(account)
    addressable_template.expand(uri: ActivityPub::TagManager.instance.uri_for(account)).to_s
  end

  def interact_address_for(status)
    addressable_template.expand(uri: ActivityPub::TagManager.instance.uri_for(status)).to_s
  end

  private

  def normalize_acct(value)
    return if value.blank?

    username, domain = value.strip.gsub(/\A@/, '').split('@')

    domain = if TagManager.instance.local_domain?(domain)
               nil
             else
               TagManager.instance.normalize_domain(domain)
             end

    [username, domain].compact.join('@')
  rescue Addressable::URI::InvalidURIError
    value
  end

  def fetch_template!
    return missing_resource_error if acct.blank?

    _, domain = acct.split('@')

    if domain.nil?
      @addressable_template = Addressable::Template.new("#{authorize_interaction_url}?uri={uri}")
    elsif redirect_uri_template.nil?
      missing_resource_error
    else
      @addressable_template = Addressable::Template.new(redirect_uri_template)
    end
  end

  def redirect_uri_template
    acct_resource&.link('http://ostatus.org/schema/1.0/subscribe', 'template')
  end

  def acct_resource
    @acct_resource ||= Webfinger.new("acct:#{acct}").perform
  rescue Webfinger::Error, HTTP::ConnectionError
    nil
  end

  def missing_resource_error
    errors.add(:acct, I18n.t('remote_follow.missing_resource'))
  end
end
