# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  class WrappedActor
    attr_reader :wrapped_account

    def initialize(wrapped_account)
      @wrapped_account = wrapped_account
    end

    delegate :uri, :keypair, to: :wrapped_account
  end

  controller do
    include SignatureVerification

    before_action :require_actor_signature!, only: [:signature_required]

    def success
      head 200
    end

    def alternative_success
      head 200
    end

    def signature_required
      head 200
    end
  end

  before do
    routes.draw do
      match via: %i(get post), 'success' => 'anonymous#success'
      match via: %i(get post), 'signature_required' => 'anonymous#signature_required'
    end
  end

  context 'without signature header' do
    before do
      get :success
    end

    describe '#signed_request?' do
      it 'returns false' do
        expect(controller.signed_request?).to be false
      end
    end

    describe '#signed_request_account' do
      it 'returns nil' do
        expect(controller.signed_request_account).to be_nil
      end
    end
  end

  context 'with signature header' do
    let!(:author) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/actor') }

    context 'without body' do
      before do
        get :success

        fake_request = Request.new(:get, request.url)
        fake_request.on_behalf_of(author)

        request.headers.merge!(fake_request.headers)
      end

      describe '#signed_request?' do
        it 'returns true' do
          expect(controller.signed_request?).to be true
        end
      end

      describe '#signed_request_account' do
        it 'returns an account' do
          expect(controller.signed_request_account).to eq author
        end

        it 'returns nil when path does not match' do
          request.path = '/alternative-path'
          expect(controller.signed_request_account).to be_nil
        end

        it 'returns nil when method does not match' do
          post :success
          expect(controller.signed_request_account).to be_nil
        end
      end
    end

    context 'with a valid actor that is not an Account' do
      let(:actor) { WrappedActor.new(author) }

      before do
        get :success

        fake_request = Request.new(:get, request.url)
        fake_request.on_behalf_of(author)

        request.headers.merge!(fake_request.headers)

        allow(ActivityPub::TagManager.instance).to receive(:uri_to_actor).with(anything) do
          actor
        end
      end

      describe '#signed_request?' do
        it 'returns true' do
          expect(controller.signed_request?).to be true
        end
      end

      describe '#signed_request_account' do
        it 'returns nil' do
          expect(controller.signed_request_account).to be_nil
        end
      end

      describe '#signed_request_actor' do
        it 'returns the expected actor' do
          expect(controller.signed_request_actor).to eq actor
        end
      end
    end

    context 'with request with unparseable Date header' do
      before do
        get :success

        fake_request = Request.new(:get, request.url)
        fake_request.add_headers({ 'Date' => 'wrong date' })
        fake_request.on_behalf_of(author)

        request.headers.merge!(fake_request.headers)
      end

      describe '#signed_request?' do
        it 'returns true' do
          expect(controller.signed_request?).to be true
        end
      end

      describe '#signed_request_account' do
        it 'returns nil' do
          expect(controller.signed_request_account).to be_nil
        end
      end

      describe '#signature_verification_failure_reason' do
        it 'contains an error description' do
          controller.signed_request_account
          expect(controller.signature_verification_failure_reason[:error]).to eq 'Invalid Date header: not RFC 2616 compliant date: "wrong date"'
        end
      end
    end

    context 'with request older than a day' do
      before do
        get :success

        fake_request = Request.new(:get, request.url)
        fake_request.add_headers({ 'Date' => 2.days.ago.utc.httpdate })
        fake_request.on_behalf_of(author)

        request.headers.merge!(fake_request.headers)
      end

      describe '#signed_request?' do
        it 'returns true' do
          expect(controller.signed_request?).to be true
        end
      end

      describe '#signed_request_account' do
        it 'returns nil' do
          expect(controller.signed_request_account).to be_nil
        end
      end

      describe '#signature_verification_failure_reason' do
        it 'contains an error description' do
          controller.signed_request_account
          expect(controller.signature_verification_failure_reason[:error]).to eq 'Signed request date outside acceptable time window'
        end
      end
    end

    context 'with inaccessible key' do
      before do
        get :success

        author = Fabricate(:account, domain: 'localhost:5000', uri: 'http://localhost:5000/actor')
        fake_request = Request.new(:get, request.url)
        fake_request.on_behalf_of(author)
        author.destroy

        request.headers.merge!(fake_request.headers)

        stub_request(:get, 'http://localhost:5000/actor#main-key').to_raise(Mastodon::HostValidationError)
      end

      describe '#signed_request?' do
        it 'returns true' do
          expect(controller.signed_request?).to be true
        end
      end

      describe '#signed_request_account' do
        it 'returns nil' do
          expect(controller.signed_request_account).to be_nil
        end
      end
    end

    context 'with body' do
      before do
        allow(controller).to receive(:actor_refresh_key!).and_return(author)
        post :success, body: 'Hello world'

        fake_request = Request.new(:post, request.url, body: 'Hello world')
        fake_request.on_behalf_of(author)

        request.headers.merge!(fake_request.headers)
      end

      describe '#signed_request?' do
        it 'returns true' do
          expect(controller.signed_request?).to be true
        end
      end

      describe '#signed_request_account' do
        it 'returns an account' do
          expect(controller.signed_request_account).to eq author
        end
      end

      context 'when path does not match' do
        before do
          request.path = '/alternative-path'
        end

        describe '#signed_request_account' do
          it 'returns nil' do
            expect(controller.signed_request_account).to be_nil
          end
        end

        describe '#signature_verification_failure_reason' do
          it 'contains an error description' do
            controller.signed_request_account
            expect(controller.signature_verification_failure_reason[:error]).to include('using rsa-sha256 (RSASSA-PKCS1-v1_5 with SHA-256)')
            expect(controller.signature_verification_failure_reason[:signed_string]).to include("(request-target): post /alternative-path\n")
          end
        end
      end

      context 'when method does not match' do
        before do
          get :success
        end

        describe '#signed_request_account' do
          it 'returns nil' do
            expect(controller.signed_request_account).to be_nil
          end
        end
      end

      context 'when body has been tampered' do
        before do
          post :success, body: 'doo doo doo'
        end

        describe '#signed_request_account' do
          it 'returns nil when body has been tampered' do
            expect(controller.signed_request_account).to be_nil
          end
        end
      end
    end
  end

  context 'when a signature is required' do
    before do
      get :signature_required
    end

    context 'without signature header' do
      it 'returns HTTP 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an error' do
        expect(Oj.load(response.body)['error']).to eq 'Request not signed'
      end
    end
  end
end
