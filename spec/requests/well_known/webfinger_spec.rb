# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The /.well-known/webfinger endpoint' do
  subject(:perform_request!) { get webfinger_url(resource: resource) }

  let(:alternate_domains) { [] }
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:resource) { nil }

  around do |example|
    tmp = Rails.configuration.x.alternate_domains
    Rails.configuration.x.alternate_domains = alternate_domains
    example.run
    Rails.configuration.x.alternate_domains = tmp
  end

  shared_examples 'a successful response' do
    it 'returns http success with correct media type and headers and body json' do
      expect(response).to have_http_status(200)

      expect(response.headers['Vary']).to eq('Origin')

      expect(response.media_type).to eq 'application/jrd+json'

      expect(response.parsed_body)
        .to include(
          subject: eq('acct:alice@cb6e6126.ngrok.io'),
          aliases: include('https://cb6e6126.ngrok.io/@alice', 'https://cb6e6126.ngrok.io/users/alice')
        )
    end
  end

  context 'when an account exists' do
    let(:resource) { alice.to_webfinger_s }

    before do
      perform_request!
    end

    it_behaves_like 'a successful response'
  end

  context 'when an account is temporarily suspended' do
    let(:resource) { alice.to_webfinger_s }

    before do
      alice.suspend!
      perform_request!
    end

    it_behaves_like 'a successful response'
  end

  context 'when an account is permanently suspended or deleted' do
    let(:resource) { alice.to_webfinger_s }

    before do
      alice.suspend!
      alice.deletion_request.destroy
      perform_request!
    end

    it 'returns http gone' do
      expect(response).to have_http_status(410)
    end
  end

  context 'when an account is not found' do
    let(:resource) { 'acct:not@existing.com' }

    before do
      perform_request!
    end

    it 'returns http not found' do
      expect(response).to have_http_status(404)
    end
  end

  context 'with an alternate domain' do
    let(:alternate_domains) { ['foo.org'] }

    before do
      perform_request!
    end

    context 'when an account exists' do
      let(:resource) do
        username, = alice.to_webfinger_s.split('@')
        "#{username}@foo.org"
      end

      it_behaves_like 'a successful response'
    end

    context 'when the domain is wrong' do
      let(:resource) do
        username, = alice.to_webfinger_s.split('@')
        "#{username}@bar.org"
      end

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  context 'when the old name scheme is used to query the instance actor' do
    let(:resource) do
      "#{Rails.configuration.x.local_domain}@#{Rails.configuration.x.local_domain}"
    end

    before do
      perform_request!
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'sets only a Vary Origin header' do
      expect(response.headers['Vary']).to eq('Origin')
    end

    it 'returns application/jrd+json' do
      expect(response.media_type).to eq 'application/jrd+json'
    end

    it 'returns links for the internal account' do
      expect(response.parsed_body)
        .to include(
          subject: 'acct:mastodon.internal@cb6e6126.ngrok.io',
          aliases: ['https://cb6e6126.ngrok.io/actor']
        )
    end
  end

  context 'with no resource parameter' do
    let(:resource) { nil }

    before do
      perform_request!
    end

    it 'returns http bad request' do
      expect(response).to have_http_status(400)
    end
  end

  context 'with a nonsense parameter' do
    let(:resource) { 'df/:dfkj' }

    before do
      perform_request!
    end

    it 'returns http bad request' do
      expect(response).to have_http_status(400)
    end
  end

  context 'when an account has an avatar' do
    let(:alice) { Fabricate(:account, username: 'alice', avatar: attachment_fixture('attachment.jpg')) }
    let(:resource) { alice.to_webfinger_s }

    it 'returns avatar in response' do
      perform_request!

      expect(response_avatar_link)
        .to be_present
        .and include(
          type: eq(alice.avatar.content_type),
          href: eq(Addressable::URI.new(host: Rails.configuration.x.local_domain, path: alice.avatar.to_s, scheme: 'https').to_s)
        )
    end

    context 'with limited federation mode' do
      before do
        allow(Rails.configuration.x).to receive(:limited_federation_mode).and_return(true)
      end

      it 'does not return avatar in response' do
        perform_request!

        expect(response_avatar_link)
          .to be_nil
      end
    end

    context 'when enabling DISALLOW_UNAUTHENTICATED_API_ACCESS' do
      around do |example|
        ClimateControl.modify DISALLOW_UNAUTHENTICATED_API_ACCESS: 'true' do
          example.run
        end
      end

      it 'does not return avatar in response' do
        perform_request!

        expect(response_avatar_link)
          .to be_nil
      end
    end
  end

  context 'when an account does not have an avatar' do
    let(:alice) { Fabricate(:account, username: 'alice', avatar: nil) }
    let(:resource) { alice.to_webfinger_s }

    before do
      perform_request!
    end

    it 'does not return avatar in response' do
      expect(response_avatar_link)
        .to be_nil
    end
  end

  context 'with different headers' do
    describe 'requested with standard accepts headers' do
      it 'returns a json response' do
        get webfinger_url(resource: alice.to_webfinger_s)

        expect(response).to have_http_status(200)
        expect(response.media_type).to eq 'application/jrd+json'
      end
    end

    describe 'asking for json format' do
      it 'returns a json response for json format' do
        get webfinger_url(resource: alice.to_webfinger_s, format: :json)

        expect(response).to have_http_status(200)
        expect(response.media_type).to eq 'application/jrd+json'
      end

      it 'returns a json response for json accept header' do
        headers = { 'HTTP_ACCEPT' => 'application/jrd+json' }
        get webfinger_url(resource: alice.to_webfinger_s), headers: headers

        expect(response).to have_http_status(200)
        expect(response.media_type).to eq 'application/jrd+json'
      end
    end
  end

  private

  def response_avatar_link
    response
      .parsed_body[:links]
      .find { |link| link[:rel] == 'http://webfinger.net/rel/avatar' }
  end
end
