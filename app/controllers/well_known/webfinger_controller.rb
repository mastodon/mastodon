# frozen_string_literal: true
#
# Mastodon, a GNU Social-compatible microblogging server
# Copyright (C) 2016-2017 Eugen Rochko & al (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

module WellKnown
  class WebfingerController < ApplicationController
    def show
      @account = Account.find_local!(username_from_resource)
      @canonical_account_uri = @account.to_webfinger_s
      @magic_key = pem_to_magic_key(@account.keypair.public_key)

      respond_to do |format|
        format.any(:json, :html) do
          render formats: :json, content_type: 'application/jrd+json'
        end

        format.xml do
          render content_type: 'application/xrd+xml'
        end
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
