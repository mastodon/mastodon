# frozen_string_literal: true

require 'rails_helper'

dest_nok = 'https://invalid.owas.testing.net'
dest_ok = 'https://valid.owas.testing.net'

# mock an encrypted token that can be decrypted by the user
def encrypt_token
  public_key = OpenSSL::PKey.read(user.account.public_key)
  Base64.urlsafe_encode64(public_key.public_encrypt(token))
end

def generate_args
  "?f=&owt=#{token}"
end

RSpec.configure do |config|
  config.before do
    stub_request(:post, "#{dest_nok}/owa").
      # run1: no HTTP OK status
      to_return({ status: 404 }).then.
      # run2: success = false
      to_return({ body: { 'success' => false }.to_json.to_s }).
      # run3: success = true, but no token provided
      to_return({ body: { 'success' => true }.to_json.to_s }).
      # run4: success = true, wrong token provided
      to_return({ body: { 'success' => true, 'encrypted_token' => 'LALA' }.to_json.to_s })

    # HTTP OK response, success = true, correct token provided
    stub_request(:post, "#{dest_ok}/owa")
      .to_return({ body: { 'success' => true, 'encrypted_token' => encrypted_token }.to_json.to_s })
  end
  config.include Devise::Test::IntegrationHelpers, type: :request
end

RSpec.describe 'GET /magic' do
  let(:user) { Fabricate(:user) }
  let(:token) { SecureRandom.hex(32) }
  let(:encrypted_token) { encrypt_token }

  endp = '/magic'
  owa_endp = "#{endp}?owa=1"
  owa_dest_nok_endp = "#{owa_endp}&dest=#{dest_nok}"
  bdest_nok = dest_nok.unpack1('H*')
  owa_bdest_nok_endp = "#{owa_endp}&bdest=#{bdest_nok}"

  it 'redirects to sign in when no user is signed in' do
    get owa_dest_nok_endp
    expect(response).to redirect_to('/auth/sign_in')
  end

  it 'falls through to destination in case of invalid response received from OpenWebAuth server' do
    sign_in user

    # run1: no HTTP OK status
    get owa_dest_nok_endp
    expect(response).to have_http_status(302)
    expect(response).to redirect_to(dest_nok)

    # run2: success = false
    get owa_dest_nok_endp
    expect(response).to have_http_status(302)
    expect(response).to redirect_to(dest_nok)

    # run3: success = true, but no token provided
    get owa_bdest_nok_endp
    expect(response).to have_http_status(302)
    expect(response).to redirect_to(dest_nok)

    # run4: success = true, invalid token provided
    get owa_bdest_nok_endp
    expect(response).to have_http_status(302)
    expect(response).to redirect_to(dest_nok)
  end

  # Happy case testing - destination is a working OpenWebAuth server
  owa_dest_ok_endp = "#{owa_endp}&dest=#{dest_ok}"
  bdest_ok = dest_ok.unpack1('H*')
  owa_bdest_ok_endp = "#{owa_endp}&bdest=#{bdest_ok}"

  it 'returns a remotely authenticated redirect to the destination when using dest parameter' do
    sign_in user
    get owa_dest_ok_endp
    expect(response).to have_http_status(302)
    expect(response).to redirect_to("#{dest_ok}#{generate_args}")
  end

  it 'returns a remotely authenticated redirect to the destination when using hex encoded dest parameter' do
    sign_in user
    get owa_bdest_ok_endp
    expect(response).to have_http_status(302)
    expect(response).to redirect_to("#{dest_ok}#{generate_args}")
  end
end
