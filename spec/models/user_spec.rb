require 'rails_helper'
require 'devise_two_factor/spec_helpers'

RSpec.describe User, type: :model do
  it_behaves_like 'two_factor_backupable'

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
      user = Fabricate.build(:user, allowed_languages: [''])
      user.valid?
      expect(user.allowed_languages).to eq []
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
    it 'sets otp_required_for_login to false' do
      user = Fabricate.build(:user, otp_required_for_login: true)
      user.disable_two_factor!
      expect(user.otp_required_for_login).to be false
    end

    it 'clears otp_backup_codes' do
      user = Fabricate.build(:user, otp_backup_codes: %w[dummy dummy])
      user.disable_two_factor!
      expect(user.otp_backup_codes.empty?).to be true
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

    it 'should not allow a user to be created with a specific blacklisted subdomain even if the top domain is whitelisted' do
      old_blacklist = Rails.configuration.x.email_blacklist
      Rails.configuration.x.email_domains_blacklist = 'blacklisted.mastodon.space'

      user = User.new(email: 'foo@blacklisted.mastodon.space', account: account, password: password)
      expect(user.valid?).to be_falsey

      Rails.configuration.x.email_domains_blacklist = old_blacklist
    end
  end
end
