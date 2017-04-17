# frozen_string_literal: true

module WellKnown
  class WebfingerController < ApplicationController
    def show
      @account = Account.find_local!(username_from_resource)
      @canonical_account_uri = @account.to_webfinger_s
      @magic_key = pem_to_magic_key(@account.keypair.public_key)

      respond_to do |format|
        format.xml  { render content_type: 'application/xrd+xml' }
        format.json { render content_type: 'application/jrd+json' }
      end
    rescue ActiveRecord::RecordNotFound
      head 404
    end

    private

    def username_from_resource
      WebfingerResource.new(resource_param).username
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
end
