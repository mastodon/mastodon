# frozen_string_literal: true

require 'rails_helper'

describe 'Self-destruct mode' do
  before do
    allow(SelfDestructHelper).to receive(:self_destruct?).and_return(true)
  end

  shared_examples 'generic logged out request' do |path|
    it 'returns 410 gone and mentions self-destruct' do
      get path, headers: { 'Accept' => 'text/html' }

      expect(response).to have_http_status(410)
      expect(response.body).to include(I18n.t('self_destruct.title'))
    end
  end

  shared_examples 'accessible logged-in endpoint' do |path|
    it 'returns 200 ok' do
      get path

      expect(response).to have_http_status(200)
    end
  end

  shared_examples 'ActivityPub request' do |path|
    context 'without signature' do
      it 'returns 410 gone' do
        get path, headers: {
          'Accept' => 'application/activity+json, application/ld+json; profile="https://www.w3.org/ns/activitystreams"',
        }

        expect(response).to have_http_status(410)
      end
    end

    context 'with invalid signature' do
      it 'returns 410 gone' do
        get path, headers: {
          'Accept' => 'application/activity+json, application/ld+json; profile="https://www.w3.org/ns/activitystreams"',
          'Signature' => 'keyId="https://remote.domain/users/bob#main-key",algorithm="rsa-sha256",headers="date host (request-target)",signature="bar"',
        }

        expect(response).to have_http_status(410)
      end
    end
  end

  context 'when requesting various unavailable endpoints' do
    it_behaves_like 'generic logged out request', '/'
    it_behaves_like 'generic logged out request', '/about'
    it_behaves_like 'generic logged out request', '/public'
  end

  context 'when requesting a suspended account' do
    let(:suspended) { Fabricate(:account, username: 'suspended') }

    before do
      suspended.suspend!
    end

    it_behaves_like 'generic logged out request', '/@suspended'
    it_behaves_like 'ActivityPub request', '/users/suspended'
    it_behaves_like 'ActivityPub request', '/users/suspended/followers'
    it_behaves_like 'ActivityPub request', '/users/suspended/outbox'
  end

  context 'when requesting a non-suspended account' do
    before do
      Fabricate(:account, username: 'bob')
    end

    it_behaves_like 'generic logged out request', '/@bob'
    it_behaves_like 'ActivityPub request', '/users/bob'
    it_behaves_like 'ActivityPub request', '/users/bob/followers'
    it_behaves_like 'ActivityPub request', '/users/bob/outbox'
  end

  context 'when accessing still-enabled endpoints when logged in' do
    let(:user) { Fabricate(:user) }

    before do
      sign_in(user)
    end

    it_behaves_like 'accessible logged-in endpoint', '/auth/edit'
    it_behaves_like 'accessible logged-in endpoint', '/settings/export'
    it_behaves_like 'accessible logged-in endpoint', '/settings/login_activities'
    it_behaves_like 'accessible logged-in endpoint', '/settings/exports/follows.csv'
  end
end
