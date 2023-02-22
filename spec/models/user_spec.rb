# frozen_string_literal: true

require 'rails_helper'
require 'devise_two_factor/spec_helpers'

RSpec.describe User, type: :model do
  let(:password) { 'abcd1234' }
  let(:account) { Fabricate(:account, username: 'alice') }

  it_behaves_like 'two_factor_backupable'

  describe 'otp_secret' do
    it 'is encrypted with OTP_SECRET environment variable' do
      user = Fabricate.build(:user,
                             encrypted_otp_secret: "Fttsy7QAa0edaDfdfSz094rRLAxc8cJweDQ4BsWH/zozcdVA8o9GLqcKhn2b\nGi/V\n",
                             encrypted_otp_secret_iv: 'rys3THICkr60BoWC',
                             encrypted_otp_secret_salt: '_LMkAGvdg7a+sDIKjI3mR2Q==')

      expect(user.otp_secret).to eq 'anotpsecretthatshouldbeencrypted'
    end
  end

  describe 'validations' do
    it 'is invalid without an account' do
      user = Fabricate.build(:user, account: nil)
      user.valid?
      expect(user).to model_have_error_on_field(:account)
    end

    it 'is invalid without a valid locale' do
      user = Fabricate.build(:user, locale: 'toto')
      user.valid?
      expect(user).to model_have_error_on_field(:locale)
    end

    it 'is invalid without a valid email' do
      user = Fabricate.build(:user, email: 'john@')
      user.valid?
      expect(user).to model_have_error_on_field(:email)
    end

    it 'is valid with an invalid e-mail that has already been saved' do
      user = Fabricate.build(:user, email: 'invalid-email')
      user.save(validate: false)
      expect(user.valid?).to be true
    end

    it 'cleans out empty string from languages' do
      user = Fabricate.build(:user, chosen_languages: [''])
      user.valid?
      expect(user.chosen_languages).to be_nil
    end
  end

  describe 'scopes' do
    describe 'recent' do
      it 'returns an array of recent users ordered by id' do
        user_1 = Fabricate(:user)
        user_2 = Fabricate(:user)
        expect(User.recent).to eq [user_2, user_1]
      end
    end

    describe 'confirmed' do
      it 'returns an array of users who are confirmed' do
        user_1 = Fabricate(:user, confirmed_at: nil)
        user_2 = Fabricate(:user, confirmed_at: Time.zone.now)
        expect(User.confirmed).to match_array([user_2])
      end
    end

    describe 'inactive' do
      it 'returns a relation of inactive users' do
        specified = Fabricate(:user, current_sign_in_at: 15.days.ago)
        Fabricate(:user, current_sign_in_at: 6.days.ago)

        expect(User.inactive).to match_array([specified])
      end
    end

    describe 'matches_email' do
      it 'returns a relation of users whose email starts with the given string' do
        specified = Fabricate(:user, email: 'specified@spec')
        Fabricate(:user, email: 'unspecified@spec')

        expect(User.matches_email('specified')).to match_array([specified])
      end
    end

    describe 'matches_ip' do
      it 'returns a relation of users whose ip address is matching with the given CIDR' do
        user1 = Fabricate(:user)
        user2 = Fabricate(:user)
        Fabricate(:session_activation, user: user1, ip: '2160:2160::22', session_id: '1')
        Fabricate(:session_activation, user: user1, ip: '2160:2160::23', session_id: '2')
        Fabricate(:session_activation, user: user2, ip: '2160:8888::24', session_id: '3')
        Fabricate(:session_activation, user: user2, ip: '2160:8888::25', session_id: '4')

        expect(User.matches_ip('2160:2160::/32')).to match_array([user1])
      end
    end
  end

  describe 'blacklist' do
    around(:each) do |example|
      old_blacklist = Rails.configuration.x.email_blacklist

      Rails.configuration.x.email_domains_blacklist = 'mvrht.com'

      example.run

      Rails.configuration.x.email_domains_blacklist = old_blacklist
    end

    it 'allows a non-blacklisted user to be created' do
      user = User.new(email: 'foo@example.com', account: account, password: password, agreement: true)

      expect(user.valid?).to be_truthy
    end

    it 'does not allow a blacklisted user to be created' do
      user = User.new(email: 'foo@mvrht.com', account: account, password: password, agreement: true)

      expect(user.valid?).to be_falsey
    end

    it 'does not allow a subdomain blacklisted user to be created' do
      user = User.new(email: 'foo@mvrht.com.topdomain.tld', account: account, password: password, agreement: true)

      expect(user.valid?).to be_falsey
    end
  end

  describe '#confirmed?' do
    it 'returns true when a confirmed_at is set' do
      user = Fabricate.build(:user, confirmed_at: Time.now.utc)
      expect(user.confirmed?).to be true
    end

    it 'returns false if a confirmed_at is nil' do
      user = Fabricate.build(:user, confirmed_at: nil)
      expect(user.confirmed?).to be false
    end
  end

  describe '#confirm' do
    subject { user.confirm }

    let(:new_email) { 'new-email@example.com' }

    before do
      allow(TriggerWebhookWorker).to receive(:perform_async)
    end

    context 'when the user is already confirmed' do
      let!(:user) { Fabricate(:user, confirmed_at: Time.now.utc, approved: true, unconfirmed_email: new_email) }

      it 'sets email to unconfirmed_email' do
        expect { subject }.to change { user.reload.email }.to(new_email)
      end

      it 'does not trigger the account.approved Web Hook' do
        subject
        expect(TriggerWebhookWorker).to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
      end
    end

    context 'when the user is a new user' do
      let(:user) { Fabricate(:user, confirmed_at: nil, unconfirmed_email: new_email) }

      context 'when the user is already approved' do
        around(:example) do |example|
          registrations_mode = Setting.registrations_mode
          Setting.registrations_mode = 'approved'

          example.run

          Setting.registrations_mode = registrations_mode
        end

        before do
          user.approve!
        end

        it 'sets email to unconfirmed_email' do
          expect { subject }.to change { user.reload.email }.to(new_email)
        end

        it 'triggers the account.approved Web Hook' do
          user.confirm
          expect(TriggerWebhookWorker).to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
        end
      end

      context 'when the user does not require explicit approval' do
        around(:example) do |example|
          registrations_mode = Setting.registrations_mode
          Setting.registrations_mode = 'open'

          example.run

          Setting.registrations_mode = registrations_mode
        end

        it 'sets email to unconfirmed_email' do
          expect { subject }.to change { user.reload.email }.to(new_email)
        end

        it 'triggers the account.approved Web Hook' do
          user.confirm
          expect(TriggerWebhookWorker).to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
        end
      end

      context 'when the user requires explicit approval but is not approved' do
        around(:example) do |example|
          registrations_mode = Setting.registrations_mode
          Setting.registrations_mode = 'approved'

          example.run

          Setting.registrations_mode = registrations_mode
        end

        it 'sets email to unconfirmed_email' do
          expect { subject }.to change { user.reload.email }.to(new_email)
        end

        it 'does not trigger the account.approved Web Hook' do
          subject
          expect(TriggerWebhookWorker).to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
        end
      end
    end
  end

  describe '#approve!' do
    subject { user.approve! }

    around(:example) do |example|
      registrations_mode = Setting.registrations_mode
      Setting.registrations_mode = 'approved'

      example.run

      Setting.registrations_mode = registrations_mode
    end

    before do
      allow(TriggerWebhookWorker).to receive(:perform_async)
    end

    context 'when the user is already confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: Time.now.utc, approved: false) }

      it 'sets the approved flag' do
        expect { subject }.to change { user.reload.approved? }.to(true)
      end

      it 'triggers the account.approved Web Hook' do
        subject
        expect(TriggerWebhookWorker).to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
      end
    end

    context 'when the user is not confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: nil, approved: false) }

      it 'sets the approved flag' do
        expect { subject }.to change { user.reload.approved? }.to(true)
      end

      it 'does not trigger the account.approved Web Hook' do
        subject
        expect(TriggerWebhookWorker).to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
      end
    end
  end

  describe '#disable_two_factor!' do
    it 'saves false for otp_required_for_login' do
      user = Fabricate.build(:user, otp_required_for_login: true)
      user.disable_two_factor!
      expect(user.reload.otp_required_for_login).to be false
    end

    it 'saves nil for otp_secret' do
      user = Fabricate.build(:user, otp_secret: 'oldotpcode')
      user.disable_two_factor!
      expect(user.reload.otp_secret).to be_nil
    end

    it 'saves cleared otp_backup_codes' do
      user = Fabricate.build(:user, otp_backup_codes: %w(dummy dummy))
      user.disable_two_factor!
      expect(user.reload.otp_backup_codes.empty?).to be true
    end
  end

  describe '#send_confirmation_instructions' do
    around do |example|
      queue_adapter = ActiveJob::Base.queue_adapter
      example.run
      ActiveJob::Base.queue_adapter = queue_adapter
    end

    it 'delivers confirmation instructions later' do
      user = Fabricate(:user)
      ActiveJob::Base.queue_adapter = :test

      expect { user.send_confirmation_instructions }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  describe 'settings' do
    it 'is instance of Settings::ScopedSettings' do
      user = Fabricate.build(:user)
      expect(user.settings).to be_a Settings::ScopedSettings
    end
  end

  describe '#setting_default_privacy' do
    it 'returns default privacy setting if user has configured' do
      user = Fabricate(:user)
      user.settings[:default_privacy] = 'unlisted'
      expect(user.setting_default_privacy).to eq 'unlisted'
    end

    it "returns 'private' if user has not configured default privacy setting and account is locked" do
      user = Fabricate(:account, locked: true).user
      expect(user.setting_default_privacy).to eq 'private'
    end

    it "returns 'public' if user has not configured default privacy setting and account is not locked" do
      user = Fabricate(:account, locked: false).user
      expect(user.setting_default_privacy).to eq 'public'
    end
  end

  describe 'whitelist' do
    around(:each) do |example|
      old_whitelist = Rails.configuration.x.email_domains_whitelist

      Rails.configuration.x.email_domains_whitelist = 'mastodon.space'

      example.run

      Rails.configuration.x.email_domains_whitelist = old_whitelist
    end

    it 'does not allow a user to be created unless they are whitelisted' do
      user = User.new(email: 'foo@example.com', account: account, password: password, agreement: true)
      expect(user.valid?).to be_falsey
    end

    it 'allows a user to be created if they are whitelisted' do
      user = User.new(email: 'foo@mastodon.space', account: account, password: password, agreement: true)
      expect(user.valid?).to be_truthy
    end

    it 'does not allow a user with a whitelisted top domain as subdomain in their email address to be created' do
      user = User.new(email: 'foo@mastodon.space.userdomain.com', account: account, password: password, agreement: true)
      expect(user.valid?).to be_falsey
    end

    context do
      around do |example|
        old_blacklist = Rails.configuration.x.email_blacklist
        example.run
        Rails.configuration.x.email_domains_blacklist = old_blacklist
      end

      it 'does not allow a user to be created with a specific blacklisted subdomain even if the top domain is whitelisted' do
        Rails.configuration.x.email_domains_blacklist = 'blacklisted.mastodon.space'

        user = User.new(email: 'foo@blacklisted.mastodon.space', account: account, password: password)
        expect(user.valid?).to be_falsey
      end
    end
  end

  it_behaves_like 'Settings-extended' do
    def create!
      User.create!(account: Fabricate(:account, user: nil), email: 'foo@mastodon.space', password: 'abcd1234', agreement: true)
    end

    def fabricate
      Fabricate(:user)
    end
  end

  describe 'token_for_app' do
    let(:user) { Fabricate(:user) }
    let(:app) { Fabricate(:application, owner: user) }

    it 'returns a token' do
      expect(user.token_for_app(app)).to be_a(Doorkeeper::AccessToken)
    end

    it 'persists a token' do
      t = user.token_for_app(app)
      expect(user.token_for_app(app)).to eql(t)
    end

    it 'is nil if user does not own app' do
      app.update!(owner: nil)

      expect(user.token_for_app(app)).to be_nil
    end
  end

  describe '#disable!' do
    subject(:user) { Fabricate(:user, disabled: false, current_sign_in_at: current_sign_in_at, last_sign_in_at: nil) }

    let(:current_sign_in_at) { Time.zone.now }

    before do
      user.disable!
    end

    it 'disables user' do
      expect(user).to have_attributes(disabled: true)
    end
  end

  describe '#enable!' do
    subject(:user) { Fabricate(:user, disabled: true) }

    before do
      user.enable!
    end

    it 'enables user' do
      expect(user).to have_attributes(disabled: false)
    end
  end

  describe '#reset_password!' do
    subject(:user) { Fabricate(:user, password: 'foobar12345') }

    let!(:session_activation) { Fabricate(:session_activation, user: user) }
    let!(:access_token) { Fabricate(:access_token, resource_owner_id: user.id) }
    let!(:web_push_subscription) { Fabricate(:web_push_subscription, access_token: access_token) }

    before do
      user.reset_password!
    end

    it 'changes the password immediately' do
      expect(user.external_or_valid_password?('foobar12345')).to be false
    end

    it 'deactivates all sessions' do
      expect(user.session_activations.count).to eq 0
    end

    it 'revokes all access tokens' do
      expect(Doorkeeper::AccessToken.active_for(user).count).to eq 0
    end

    it 'removes push subscriptions' do
      expect(Web::PushSubscription.where(user: user).or(Web::PushSubscription.where(access_token: access_token)).count).to eq 0
    end
  end

  describe '#confirm!' do
    subject(:user) { Fabricate(:user, confirmed_at: confirmed_at) }

    before do
      ActionMailer::Base.deliveries.clear
      user.confirm!
    end

    after { ActionMailer::Base.deliveries.clear }

    context 'when user is new' do
      let(:confirmed_at) { nil }

      it 'confirms user' do
        expect(user.confirmed_at).to be_present
      end

      it 'delivers mails' do
        expect(ActionMailer::Base.deliveries.count).to eq 2
      end
    end

    context 'when user is not new' do
      let(:confirmed_at) { Time.zone.now }

      it 'confirms user' do
        expect(user.confirmed_at).to be_present
      end

      it 'does not deliver mail' do
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end
    end
  end

  describe '#active_for_authentication?' do
    subject { user.active_for_authentication? }

    let(:user) { Fabricate.build(:user, disabled: disabled, confirmed_at: confirmed_at) }

    context 'when user is disabled' do
      let(:disabled) { true }

      context 'when user is confirmed' do
        let(:confirmed_at) { Time.zone.now }

        it { is_expected.to be true }
      end

      context 'when user is not confirmed' do
        let(:confirmed_at) { nil }

        it { is_expected.to be true }
      end
    end

    context 'when user is not disabled' do
      let(:disabled) { false }

      context 'when user is confirmed' do
        let(:confirmed_at) { Time.zone.now }

        it { is_expected.to be true }
      end

      context 'when user is not confirmed' do
        let(:confirmed_at) { nil }

        it { is_expected.to be true }
      end
    end
  end

  describe '.those_who_can' do
    pending
  end
end
