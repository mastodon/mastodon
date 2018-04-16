require_relative 'spec_helper'

describe 'Rack::Attack' do
  describe 'helpers' do
    before do
      class Rack::Attack::Request
        def remote_ip
          ip
        end
      end

      Rack::Attack.safelist('valid IP') do |req|
        req.remote_ip == "127.0.0.1"
      end
    end

    it_allows_ok_requests
  end
end
