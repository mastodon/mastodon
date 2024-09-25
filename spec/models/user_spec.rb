# frozen_string_literal: true

require 'rails_helper'
require 'devise_two_factor/spec_helpers'

RSpec.describe User do
  subject { described_class.new(account: account) }

  let(:password) { 'abcd1234' }
  let(:account) { Fabricate(:account, username: 'alice') }

  it_behaves_like 'two_factor_backupable'

  describe 'legacy_otp_secret' do
    it 'is encrypted with OTP_SECRET environment variable' do
      user = Fabricate(:user,
                       encrypted_otp_secret: "Fttsy7QAa0edaDfdfSz094rRLAxc8cJweDQ4BsWH/zozcdVA8o9GLqcKhn2b\nGi/V\n",
                       encrypted_otp_secret_iv: 'rys3THICkr60BoWC',
                       encrypted_otp_secret_salt: '_LMkAGvdg7a+sDIKjI3mR2Q==')

      expect(user.send(:legacy_otp_secret)).to eq 'anotpsecretthatshouldbeencrypted'
    end
  end

  describe 'otp_secret' do
    it 'encrypts the saved value' do
      user = Fabricate(:user, otp_secret: '123123123')

      user.reload

      expect(user.otp_secret).to eq '123123123'
      expect(user.attributes_before_type_cast[:otp_secret]).to_not eq '123123123'
    end
  end

  describe 'validations' do
    it { is_expected.to belong_to(:account).required }

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

    it 'is valid with a localhost e-mail address' do
      user = Fabricate.build(:user, email: 'admin@localhost')
      user.valid?
      expect(user.valid?).to be true
    end
  end

  describe 'Normalizations' do
    describe 'locale' do
      it { is_expected.to_not normalize(:locale).from('en') }
      it { is_expected.to normalize(:locale).from('toto').to(nil) }
    end

    describe 'time_zone' do
      it { is_expected.to_not normalize(:time_zone).from('UTC') }
      it { is_expected.to normalize(:time_zone).from('toto').to(nil) }
    end

    describe 'chosen_languages' do
      it { is_expected.to normalize(:chosen_languages).from(['en', 'fr', '']).to(%w(en fr)) }
      it { is_expected.to normalize(:chosen_languages).from(['']).to(nil) }
    end
  end

  describe 'scopes', :inline_jobs do
    describe 'recent' do
      it 'returns an array of recent users ordered by id' do
        first_user = Fabricate(:user)
        second_user = Fabricate(:user)
        expect(described_class.recent).to eq [second_user, first_user]
      end
    end

    describe 'confirmed' do
      it 'returns an array of users who are confirmed' do
        Fabricate(:user, confirmed_at: nil)
        confirmed_user = Fabricate(:user, confirmed_at: Time.zone.now)
        expect(described_class.confirmed).to contain_exactly(confirmed_user)
      end
    end

    describe 'signed_in_recently' do
      it 'returns a relation of users who have signed in during the recent period' do
        recent_sign_in_user = Fabricate(:user, current_sign_in_at: within_duration_window_days.ago)
        Fabricate(:user, current_sign_in_at: exceed_duration_window_days.ago)

        expect(described_class.signed_in_recently)
          .to contain_exactly(recent_sign_in_user)
      end
    end

    describe 'not_signed_in_recently' do
      it 'returns a relation of users who have not signed in during the recent period' do
        no_recent_sign_in_user = Fabricate(:user, current_sign_in_at: exceed_duration_window_days.ago)
        Fabricate(:user, current_sign_in_at: within_duration_window_days.ago)

        expect(described_class.not_signed_in_recently)
          .to contain_exactly(no_recent_sign_in_user)
      end
    end

    describe 'account_not_suspended' do
      it 'returns with linked accounts that are not suspended' do
        suspended_account = Fabricate(:account, suspended_at: 10.days.ago)
        non_suspended_account = Fabricate(:account, suspended_at: nil)
        suspended_user = Fabricate(:user, account: suspended_account)
        non_suspended_user = Fabricate(:user, account: non_suspended_account)

        expect(described_class.account_not_suspended)
          .to include(non_suspended_user)
          .and not_include(suspended_user)
      end
    end

    describe 'matches_email' do
      it 'returns a relation of users whose email starts with the given string' do
        specified = Fabricate(:user, email: 'specified@spec')
        Fabricate(:user, email: 'unspecified@spec')

        expect(described_class.matches_email('specified')).to contain_exactly(specified)
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

        expect(described_class.matches_ip('2160:2160::/32')).to contain_exactly(user1)
      end
    end

    def exceed_duration_window_days
      described_class::ACTIVE_DURATION + 2.days
    end

    def within_duration_window_days
      described_class::ACTIVE_DURATION - 2.days
    end
  end

  describe 'email domains denylist integration' do
    around do |example|
      original = Rails.configuration.x.email_domains_denylist

      Rails.configuration.x.email_domains_denylist = 'mvrht.com'

      example.run

      Rails.configuration.x.email_domains_denylist = original
    end

    it 'allows a user with an email domain that is not on the denylist to be created' do
      user = described_class.new(email: 'foo@example.com', account: account, password: password, agreement: true)

      expect(user).to be_valid
    end

    it 'does not allow a user with an email domain on the deylist to be created' do
      user = described_class.new(email: 'foo@mvrht.com', account: account, password: password, agreement: true)

      expect(user).to_not be_valid
    end

    it 'does not allow a user with an email where the subdomain is on the denylist to be created' do
      user = described_class.new(email: 'foo@mvrht.com.topdomain.tld', account: account, password: password, agreement: true)

      expect(user).to_not be_valid
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

      it 'sets email to unconfirmed_email and does not trigger web hook' do
        expect { subject }.to change { user.reload.email }.to(new_email)

        expect(TriggerWebhookWorker).to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
      end
    end

    context 'when the user is a new user' do
      let(:user) { Fabricate(:user, confirmed_at: nil, unconfirmed_email: new_email) }

      context 'when the user is already approved' do
        before do
          Setting.registrations_mode = 'approved'
          user.approve!
        end

        it 'sets email to unconfirmed_email and triggers `account.approved` web hook' do
          expect { subject }.to change { user.reload.email }.to(new_email)

          expect(TriggerWebhookWorker).to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
        end
      end

      context 'when the user does not require explicit approval' do
        before do
          Setting.registrations_mode = 'open'
        end

        it 'sets email to unconfirmed_email and triggers `account.approved` web hook' do
          expect { subject }.to change { user.reload.email }.to(new_email)

          expect(TriggerWebhookWorker).to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
        end
      end

      context 'when the user requires explicit approval but is not approved' do
        before do
          Setting.registrations_mode = 'approved'
        end

        it 'sets email to unconfirmed_email and does not trigger web hook' do
          expect { subject }.to change { user.reload.email }.to(new_email)

          expect(TriggerWebhookWorker).to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
        end
      end
    end
  end

  describe '#approve!' do
    subject { user.approve! }

    before do
      Setting.registrations_mode = 'approved'
      allow(TriggerWebhookWorker).to receive(:perform_async)
    end

    context 'when the user is already confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: Time.now.utc, approved: false) }

      it 'sets the approved flag and triggers `account.approved` web hook' do
        expect { subject }.to change { user.reload.approved? }.to(true)

        expect(TriggerWebhookWorker).to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
      end
    end

    context 'when the user is not confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: nil, approved: false) }

      it 'sets the approved flag and does not trigger web hook' do
        expect { subject }.to change { user.reload.approved? }.to(true)

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
    it 'is instance of UserSettings' do
      user = Fabricate(:user)
      expect(user.settings).to be_a UserSettings
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

  describe 'allowlist integration' do
    around do |example|
      original = Rails.configuration.x.email_domains_allowlist

      Rails.configuration.x.email_domains_allowlist = 'mastodon.space'

      example.run

      Rails.configuration.x.email_domains_allowlist = original
    end

    it 'does not allow a user to be created when their email is not on the allowlist' do
      user = described_class.new(email: 'foo@example.com', account: account, password: password, agreement: true)
      expect(user).to_not be_valid
    end

    it 'allows a user to be created when their email is on the allowlist' do
      user = described_class.new(email: 'foo@mastodon.space', account: account, password: password, agreement: true)
      expect(user).to be_valid
    end

    it 'does not allow a user with an email subdomain included on the top level domain allowlist to be created' do
      user = described_class.new(email: 'foo@mastodon.space.userdomain.com', account: account, password: password, agreement: true)
      expect(user).to_not be_valid
    end

    context 'with a subdomain on the denylist' do
      around do |example|
        original = Rails.configuration.x.email_domains_denylist
        example.run
        Rails.configuration.x.email_domains_denylist = original
      end

      it 'does not allow a user to be created with an email subdomain on the denylist even if the top domain is on the allowlist' do
        Rails.configuration.x.email_domains_denylist = 'denylisted.mastodon.space'

        user = described_class.new(email: 'foo@denylisted.mastodon.space', account: account, password: password)
        expect(user).to_not be_valid
      end
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
    subject(:user) { Fabricate(:user, password: original_password) }

    let(:original_password) { 'foobar12345' }

    let!(:session_activation) { Fabricate(:session_activation, user: user) }
    let!(:access_token) { Fabricate(:access_token, resource_owner_id: user.id) }
    let!(:web_push_subscription) { Fabricate(:web_push_subscription, access_token: access_token) }

    let(:redis_pipeline_stub) { instance_double(Redis::Namespace, publish: nil) }

    before { stub_redis }

    it 'changes the password immediately and revokes related access' do
      expect { user.reset_password! }
        .to remove_activated_sessions
        .and remove_active_user_tokens
        .and remove_user_web_subscriptions

      expect(user)
        .to_not be_external_or_valid_password(original_password)
      expect { session_activation.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect { web_push_subscription.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(redis_pipeline_stub)
        .to have_received(:publish).with("timeline:access_token:#{access_token.id}", Oj.dump(event: :kill)).once
    end

    def remove_activated_sessions
      change(user.session_activations, :count).to(0)
    end

    def remove_active_user_tokens
      change { Doorkeeper::AccessToken.active_for(user).count }.to(0)
    end

    def remove_user_web_subscriptions
      change { Web::PushSubscription.where(user: user).or(Web::PushSubscription.where(access_token: access_token)).count }.to(0)
    end

    def stub_redis
      allow(redis)
        .to receive(:pipelined)
        .and_yield(redis_pipeline_stub)
    end
  end

  describe '#mark_email_as_confirmed!' do
    subject { user.mark_email_as_confirmed! }

    let!(:user) { Fabricate(:user, confirmed_at: confirmed_at) }

    context 'when user is new' do
      let(:confirmed_at) { nil }

      it 'confirms user and delivers welcome email', :inline_jobs do
        emails = capture_emails { subject }

        expect(user.confirmed_at).to be_present
        expect(emails.size)
          .to eq(1)
        expect(emails.first)
          .to have_attributes(
            to: contain_exactly(user.email),
            subject: eq(I18n.t('user_mailer.welcome.subject'))
          )
      end
    end

    context 'when user is not new' do
      let(:confirmed_at) { Time.zone.now }

      it 'confirms user but does not deliver welcome email' do
        emails = capture_emails { subject }

        expect(user.confirmed_at).to be_present
        expect(emails).to be_empty
      end
    end
  end

  describe '#active_for_authentication?' do
    subject { user.active_for_authentication? }

    let(:user) { Fabricate(:user, disabled: disabled, confirmed_at: confirmed_at) }

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
    before { Fabricate(:user, role: UserRole.find_by(name: 'Moderator')) }

    context 'when there are not any user roles' do
      before { UserRole.destroy_all }

      it 'returns an empty list' do
        expect(described_class.those_who_can(:manage_blocks)).to eq([])
      end
    end

    context 'when there are not users with the needed role' do
      it 'returns an empty list' do
        expect(described_class.those_who_can(:manage_blocks)).to eq([])
      end
    end

    context 'when there are users with roles' do
      let!(:admin_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

      it 'returns the users with the role' do
        expect(described_class.those_who_can(:manage_blocks)).to eq([admin_user])
      end
    end
  end
end
