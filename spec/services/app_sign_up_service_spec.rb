# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppSignUpService do
  subject { described_class.new }

  let(:app) { Fabricate(:application, scopes: 'read write') }
  let(:good_params) { { username: 'alice', password: '12345678', email: 'good@email.com', agreement: true } }
  let(:remote_ip) { IPAddr.new('198.0.2.1') }

  describe '#call' do
    let(:params) { good_params }

    shared_examples 'successful registration' do
      it 'creates an unconfirmed user with access token and the app\'s scope', :aggregate_failures do
        access_token = subject.call(app, remote_ip, params)
        expect(access_token).to_not be_nil
        expect(access_token.scopes.to_s).to eq 'read write'

        user = User.find_by(id: access_token.resource_owner_id)
        expect(user).to_not be_nil
        expect(user.confirmed?).to be false

        expect(user.account).to_not be_nil
        expect(user.invite_request).to be_nil
      end
    end

    context 'when the email address requires approval' do
      before do
        Setting.registrations_mode = 'open'
        Fabricate(:email_domain_block, allow_with_approval: true, domain: 'email.com')
      end

      it 'creates an unapproved user', :aggregate_failures do
        access_token = subject.call(app, remote_ip, params)
        expect(access_token).to_not be_nil
        expect(access_token.scopes.to_s).to eq 'read write'

        user = User.find_by(id: access_token.resource_owner_id)
        expect(user).to_not be_nil
        expect(user.confirmed?).to be false
        expect(user.approved?).to be false

        expect(user.account).to_not be_nil
        expect(user.invite_request).to be_nil
      end
    end

    context 'when the email address requires approval through MX records' do
      before do
        Setting.registrations_mode = 'open'
        Fabricate(:email_domain_block, allow_with_approval: true, domain: 'smtp.email.com')
        allow(User).to receive(:skip_mx_check?).and_return(false)

        resolver = instance_double(Resolv::DNS, :timeouts= => nil)

        allow(resolver).to receive(:getresources)
          .with('email.com', Resolv::DNS::Resource::IN::MX)
          .and_return([instance_double(Resolv::DNS::Resource::MX, exchange: 'smtp.email.com')])
        allow(resolver).to receive(:getresources).with('email.com', Resolv::DNS::Resource::IN::A).and_return([])
        allow(resolver).to receive(:getresources).with('email.com', Resolv::DNS::Resource::IN::AAAA).and_return([])
        allow(resolver).to receive(:getresources).with('smtp.email.com', Resolv::DNS::Resource::IN::A).and_return([instance_double(Resolv::DNS::Resource::IN::A, address: '2.3.4.5')])
        allow(resolver).to receive(:getresources).with('smtp.email.com', Resolv::DNS::Resource::IN::AAAA).and_return([instance_double(Resolv::DNS::Resource::IN::AAAA, address: 'fd00::2')])
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)
      end

      it 'creates an unapproved user', :aggregate_failures do
        access_token = subject.call(app, remote_ip, params)
        expect(access_token).to_not be_nil
        expect(access_token.scopes.to_s).to eq 'read write'

        user = User.find_by(id: access_token.resource_owner_id)
        expect(user).to_not be_nil
        expect(user.confirmed?).to be false
        expect(user.approved?).to be false

        expect(user.account).to_not be_nil
        expect(user.invite_request).to be_nil
      end
    end

    context 'when registrations are closed' do
      before do
        Setting.registrations_mode = 'none'
      end

      it 'raises an error', :aggregate_failures do
        expect { subject.call(app, remote_ip, good_params) }.to raise_error Mastodon::NotPermittedError
      end

      context 'when using a valid invite' do
        let(:params) { good_params.merge({ invite_code: invite.code }) }
        let(:invite) { Fabricate(:invite) }

        before do
          invite.user.approve!
        end

        it_behaves_like 'successful registration'
      end

      context 'when using an invalid invite' do
        let(:params) { good_params.merge({ invite_code: invite.code }) }
        let(:invite) { Fabricate(:invite, uses: 1, max_uses: 1) }

        it 'raises an error', :aggregate_failures do
          expect { subject.call(app, remote_ip, params) }.to raise_error Mastodon::NotPermittedError
        end
      end
    end

    it 'raises an error when params are missing' do
      expect { subject.call(app, remote_ip, {}) }.to raise_error ActiveRecord::RecordInvalid
    end

    it_behaves_like 'successful registration'

    context 'when given an invite request text' do
      it 'creates an account with invite request text' do
        access_token = subject.call(app, remote_ip, good_params.merge(reason: 'Foo bar'))
        expect(access_token).to_not be_nil
        user = User.find_by(id: access_token.resource_owner_id)
        expect(user).to_not be_nil
        expect(user.invite_request&.text).to eq 'Foo bar'
      end
    end
  end
end
