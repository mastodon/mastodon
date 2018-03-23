# frozen_string_literal: true

class RemoteFollow
  include ActiveModel::Validations

  attr_accessor :acct, :addressable_template

  validates :acct, presence: true

  def initialize(attrs = nil)
    @acct = attrs[:acct].gsub(/\A@/, '').strip if !attrs.nil? && !attrs[:acct].nil?
  end

  def valid?
    return false unless super

    populate_template
    errors.empty?
  end

  def subscribe_address_for(account)
    addressable_template.expand(uri: account.local_username_and_domain).to_s
  end

  private

  def populate_template
    if acct.blank? || redirect_url_link.nil? || redirect_url_link.template.nil?
      missing_resource_error
    else
      @addressable_template = Addressable::Template.new(redirect_uri_template)
    end
  end

  def redirect_uri_template
    redirect_url_link.template
  end

  def redirect_url_link
    acct_resource&.link('http://ostatus.org/schema/1.0/subscribe')
  end

  def acct_resource
    @_acct_resource ||= Goldfinger.finger("acct:#{acct}")
  rescue Goldfinger::Error, HTTP::ConnectionError
    nil
  end

  def missing_resource_error
    errors.add(:acct, I18n.t('remote_follow.missing_resource'))
  end
end
