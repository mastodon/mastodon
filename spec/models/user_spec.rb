require 'rails_helper'
require 'devise_two_factor/spec_helpers'

RSpec.describe User, type: :model do
  it_behaves_like 'two_factor_backupable'

  describe 'otp_secret' do
    it 'is encrypted with OTP_SECRET environment variable' do
      user = Fabricate(:user,
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

    it 'cleans out empty string from languages' do
      user = Fabricate.build(:user, filtered_languages: [''])
      user.valid?
      expect(user.filtered_languages).to eq []
    end
  end

  describe 'settings' do
    it 'inherits default settings from default yml' do
      expect(Setting.boost_modal).to eq false
      expect(Setting.interactions['must_be_follower']).to eq false

      user = User.new
      expect(user.settings.boost_modal).to eq false
      expect(user.settings.interactions['must_be_follower']).to eq false
    end

    it 'can update settings' do
      user = Fabricate(:user)
      expect(user.settings['interactions']['must_be_follower']).to eq false
      user.settings['interactions'] = user.settings['interactions'].merge('must_be_follower' => true)
      user.reload

      expect(user.settings['interactions']['must_be_follower']).to eq true
    end

    xit 'does not mutate defaults via the cache' do
      user = Fabricate(:user)
      user.settings['interactions']['must_be_follower'] = true
      # TODO
      # This mutates the global settings default such that future user
      # instances will inherit the incorrect starting values

      other = Fabricate(:user)
      expect(other.settings['interactions']['must_be_follower']).to eq false
    end
  end

  describe 'scopes' do
    describe 'recent' do
      it 'returns an array of recent users ordered by id' do
        user_1 = Fabricate(:user)
        user_2 = Fabricate(:user)
        expect(User.recent).to match_array([user_2, user_1])
      end
    end

    describe 'admins' do
      it 'returns an array of users who are admin' do
        user_1 = Fabricate(:user, admin: false)
        user_2 = Fabricate(:user, admin: true)
        expect(User.admins).to match_array([user_2])
      end
    end

    describe 'confirmed' do
      it 'returns an array of users who are confirmed' do
        user_1 = Fabricate(:user, confirmed_at: nil)
        user_2 = Fabricate(:user, confirmed_at: Time.now)
        expect(User.confirmed).to match_array([user_2])
      end
    end

    describe 'inactive' do
      it 'returns a relation of inactive users' do
        specified = Fabricate(:user, current_sign_in_at: 15.days.ago)
        Fabricate(:user, current_sign_in_at: 13.days.ago)

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

    describe 'with_recent_ip_address' do
      it 'returns a relation of users who is, or was at last time, online with the given IP address' do
        specifieds = [
          Fabricate(:user, current_sign_in_ip: '0.0.0.42', last_sign_in_ip: '0.0.0.0'),
          Fabricate(:user, current_sign_in_ip: nil, last_sign_in_ip: '0.0.0.42')
        ]
        Fabricate(:user, current_sign_in_ip: '0.0.0.0', last_sign_in_ip: '0.0.0.0')

        expect(User.with_recent_ip_address('0.0.0.42')).to eq specifieds
      end
    end
  end

  let(:account) { Fabricate(:account, username: 'alice') }
  let(:password) { 'abcd1234' }

  describe 'blacklist' do
    around(:each) do |example|
      old_blacklist = Rails.configuration.x.email_blacklist

      Rails.configuration.x.email_domains_blacklist = 'mvrht.com'

      example.run

      Rails.configuration.x.email_domains_blacklist = old_blacklist
    end

    it 'should allow a non-blacklisted user to be created' do
      user = User.new(email: 'foo@example.com', account: account, password: password)

      expect(user.valid?).to be_truthy
    end

    it 'should not allow a blacklisted user to be created' do
      user = User.new(email: 'foo@mvrht.com', account: account, password: password)

      expect(user.valid?).to be_falsey
    end

    it 'should not allow a subdomain blacklisted user to be created' do
      user = User.new(email: 'foo@mvrht.com.topdomain.tld', account: account, password: password)

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

  describe '#disable_two_factor!' do
    it 'saves false for otp_required_for_login' do
      user = Fabricate.build(:user, otp_required_for_login: true)
      user.disable_two_factor!
      expect(user.reload.otp_required_for_login).to be false
    end

    it 'saves cleared otp_backup_codes' do
      user = Fabricate.build(:user, otp_backup_codes: %w[dummy dummy])
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

      expect { user.send_confirmation_instructions }.to have_enqueued_job(ActionMailer::DeliveryJob)
    end
  end

  describe '#setting_auto_play_gif' do
    it 'returns auto-play gif setting' do
      user = Fabricate(:user)
      user.settings[:auto_play_gif] = false
      expect(user.setting_auto_play_gif).to eq false
    end
  end

  describe '#setting_boost_modal' do
    it 'returns boost modal setting' do
      user = Fabricate(:user)
      user.settings[:boost_modal] = false
      expect(user.setting_boost_modal).to eq false
    end
  end

  describe '#setting_default_privacy' do
    it 'returns default privacy setting if user has configured' do
      user = Fabricate(:user)
      user.settings[:default_privacy] = 'unlisted'
      expect(user.setting_default_privacy).to eq 'unlisted'
    end

    it "returns 'private' if user has not configured default privacy setting and account is locked" do
      user = Fabricate(:user, account: Fabricate(:account, locked: true))
      expect(user.setting_default_privacy).to eq 'private'
    end

    it "returns 'public' if user has not configured default privacy setting and account is not locked" do
      user = Fabricate(:user, account: Fabricate(:account, locked: false))
      expect(user.setting_default_privacy).to eq 'public'
    end
  end

  describe '#setting_delete_modal' do
    it 'returns delete modal setting' do
      user = Fabricate(:user)
      user.settings[:delete_modal] = false
      expect(user.setting_delete_modal).to eq false
    end
  end

  describe 'whitelist' do
    around(:each) do |example|
      old_whitelist = Rails.configuration.x.email_whitelist

      Rails.configuration.x.email_domains_whitelist = 'mastodon.space'

      example.run

      Rails.configuration.x.email_domains_whitelist = old_whitelist
    end

    it 'should not allow a user to be created unless they are whitelisted' do
      user = User.new(email: 'foo@example.com', account: account, password: password)
      expect(user.valid?).to be_falsey
    end

    it 'should allow a user to be created if they are whitelisted' do
      user = User.new(email: 'foo@mastodon.space', account: account, password: password)
      expect(user.valid?).to be_truthy
    end

    it 'should not allow a user with a whitelisted top domain as subdomain in their email address to be created' do
      user = User.new(email: 'foo@mastodon.space.userdomain.com', account: account, password: password)
      expect(user.valid?).to be_falsey
    end

    context do
      around do |example|
        old_blacklist = Rails.configuration.x.email_blacklist
        example.run
        Rails.configuration.x.email_domains_blacklist = old_blacklist
      end

      it 'should not allow a user to be created with a specific blacklisted subdomain even if the top domain is whitelisted' do
        Rails.configuration.x.email_domains_blacklist = 'blacklisted.mastodon.space'

        user = User.new(email: 'foo@blacklisted.mastodon.space', account: account, password: password)
        expect(user.valid?).to be_falsey
      end
    end
  end
end
