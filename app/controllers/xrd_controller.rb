# frozen_string_literal: true

class XrdController < ApplicationController
  before_action :set_default_format_json, only: :webfinger
  before_action :set_default_format_xml, only: :host_meta

  def host_meta
    @webfinger_template = "#{webfinger_url}?resource={uri}"

    respond_to do |format|
      format.xml { render content_type: 'application/xrd+xml' }
    end
  end

  def webfinger
    @account = Account.where(locked: false).find_local!(username_from_resource)
    @canonical_account_uri = "acct:#{@account.username}@#{Rails.configuration.x.local_domain}"
    @magic_key = pem_to_magic_key(@account.keypair.public_key)

    respond_to do |format|
      format.xml  { render content_type: 'application/xrd+xml' }
      format.json { render content_type: 'application/jrd+json' }
    end
  rescue ActiveRecord::RecordNotFound
    head 404
  end

  private

  def set_default_format_xml
    request.format = 'xml' if request.headers['HTTP_ACCEPT'].nil? && params[:format].nil?
  end

  def set_default_format_json
    request.format = 'json' if request.headers['HTTP_ACCEPT'].nil? && params[:format].nil?
  end

  def username_from_resource
    if resource_param.start_with?('acct:') || resource_param.include?('@')
      resource_param.split('@').first.gsub('acct:', '')
    else
      url = Addressable::URI.parse(resource_param)
      url.path.gsub('/users/', '')
    end
  end

  def pem_to_magic_key(public_key)
    modulus, exponent = [public_key.n, public_key.e].map do |component|
      result = []

      until component.zero?
        result << [component % 256].pack('C')
        component >>= 8
      end

      result.reverse.join
    end

    (['RSA'] + [modulus, exponent].map { |n| Base64.urlsafe_encode64(n) }).join('.')
  end

  def resource_param
    params.require(:resource)
  end
end
