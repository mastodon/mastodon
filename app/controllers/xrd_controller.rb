class XrdController < ApplicationController
  before_filter :set_format

  def host_meta
    @webfinger_template = "#{webfinger_url}?resource={uri}"
  end

  def webfinger
    @account = Account.find_by!(username: username_from_resource, domain: nil)
    @canonical_account_uri = "acct:#{@account.username}@#{Rails.configuration.x.local_domain}"
    @magic_key = pem_to_magic_key(@account.keypair.public_key)
  rescue ActiveRecord::RecordNotFound
    render nothing: true, status: 404
  end

  private

  def set_format
    request.format = 'xml'
    response.headers['Content-Type'] = 'application/xrd+xml'
  end

  def username_from_resource
    if params[:resource].start_with?('acct:')
      params[:resource].split('@').first.gsub('acct:', '')
    else
      url = Addressable::URI.parse(params[:resource])
      url.path.gsub('/users/', '')
    end
  end

  def pem_to_magic_key(public_key)
    modulus, exponent = [public_key.n, public_key.e].map do |component|
      result = ""

      until component == 0 do
        result << [component % 256].pack('C')
        component >>= 8
      end

      result.reverse!
    end

    (["RSA"] + [modulus, exponent].map { |n| Base64.urlsafe_encode64(n) }).join('.')
  end
end
