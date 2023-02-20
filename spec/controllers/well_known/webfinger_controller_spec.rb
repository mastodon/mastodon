require 'rails_helper'

describe WellKnown::WebfingerController, type: :controller do
  render_views

  describe 'GET #show' do
    subject do
      get :show, params: { resource: resource }, format: :json
    end

    let(:alternate_domains) { [] }
    let(:alice) { Fabricate(:account, username: 'alice') }
    let(:resource) { nil }

    around(:each) do |example|
      tmp = Rails.configuration.x.alternate_domains
      Rails.configuration.x.alternate_domains = alternate_domains
      example.run
      Rails.configuration.x.alternate_domains = tmp
    end

    shared_examples 'a successful response' do
      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'does not set a Vary header' do
        expect(response.headers['Vary']).to be_nil
      end

      it 'returns application/jrd+json' do
        expect(response.media_type).to eq 'application/jrd+json'
      end

      it 'returns links for the account' do
        json = body_as_json
        expect(json[:subject]).to eq 'acct:alice@cb6e6126.ngrok.io'
        expect(json[:aliases]).to include('https://cb6e6126.ngrok.io/@alice', 'https://cb6e6126.ngrok.io/users/alice')
      end
    end

    context 'when an account exists' do
      let(:resource) { alice.to_webfinger_s }

      before do
        subject
      end

      it_behaves_like 'a successful response'
    end

    context 'when an account is temporarily suspended' do
      let(:resource) { alice.to_webfinger_s }

      before do
        alice.suspend!
        subject
      end

      it_behaves_like 'a successful response'
    end

    context 'when an account is permanently suspended or deleted' do
      let(:resource) { alice.to_webfinger_s }

      before do
        alice.suspend!
        alice.deletion_request.destroy
        subject
      end

      it 'returns http gone' do
        expect(response).to have_http_status(410)
      end
    end

    context 'when an account is not found' do
      let(:resource) { 'acct:not@existing.com' }

      before do
        subject
      end

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end

    context 'with an alternate domain' do
      let(:alternate_domains) { ['foo.org'] }

      before do
        subject
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

    context 'with no resource parameter' do
      let(:resource) { nil }

      before do
        subject
      end

      it 'returns http bad request' do
        expect(response).to have_http_status(400)
      end
    end

    context 'with a nonsense parameter' do
      let(:resource) { 'df/:dfkj' }

      before do
        subject
      end

      it 'returns http bad request' do
        expect(response).to have_http_status(400)
      end
    end
  end
end
