# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppSignUpService, type: :service do
  subject { described_class.new }

  let(:app) { Fabricate(:application, scopes: 'read write') }
  let(:good_params) { { username: 'alice', password: '12345678', email: 'good@email.com', agreement: true } }
  let(:remote_ip) { IPAddr.new('198.0.2.1') }

  describe '#call' do
    it 'returns nil when registrations are closed' do
      tmp = Setting.registrations_mode
      Setting.registrations_mode = 'none'
      expect { subject.call(app, remote_ip, good_params) }.to raise_error Mastodon::NotPermittedError
      Setting.registrations_mode = tmp
    end

    it 'raises an error when params are missing' do
      expect { subject.call(app, remote_ip, {}) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'creates an unconfirmed user with access token' do
      access_token = subject.call(app, remote_ip, good_params)
      expect(access_token).to_not be_nil
      user = User.find_by(id: access_token.resource_owner_id)
      expect(user).to_not be_nil
      expect(user.confirmed?).to be false
    end

    it 'creates access token with the app\'s scopes' do
      access_token = subject.call(app, remote_ip, good_params)
      expect(access_token).to_not be_nil
      expect(access_token.scopes.to_s).to eq 'read write'
    end

    it 'creates an account' do
      access_token = subject.call(app, remote_ip, good_params)
      expect(access_token).to_not be_nil
      user = User.find_by(id: access_token.resource_owner_id)
      expect(user).to_not be_nil
      expect(user.account).to_not be_nil
      expect(user.invite_request).to be_nil
    end

    it 'creates an account with invite request text' do
      access_token = subject.call(app, remote_ip, good_params.merge(reason: 'Foo bar'))
      expect(access_token).to_not be_nil
      user = User.find_by(id: access_token.resource_owner_id)
      expect(user).to_not be_nil
      expect(user.invite_request&.text).to eq 'Foo bar'
    end
  end
end
