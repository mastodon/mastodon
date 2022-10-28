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

    def success
      head 200
    end

    def alternative_success
      head 200
    end
  end

  before do
    routes.draw { match via: [:get, :post], 'success' => 'anonymous#success' }
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

        it 'returns nil when path does not match' do
          request.path = '/alternative-path'
          expect(controller.signed_request_account).to be_nil
        end

        it 'returns nil when method does not match' do
          get :success
          expect(controller.signed_request_account).to be_nil
        end

        it 'returns nil when body has been tampered' do
          post :success, body: 'doo doo doo'
          expect(controller.signed_request_account).to be_nil
        end
      end
    end
  end
end
