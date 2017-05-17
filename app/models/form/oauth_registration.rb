# frozen_string_literal: true

class Form::OauthRegistration
  include ActiveModel::Model

  attr_accessor :user, :provider, :locale, :avatar, :email, :uid, :username, :token
  validate :validate_user

  class UnsupportedProviderError < StandardError; end

  class << self
    def from_omniauth_auth(auth)
      case auth[:provider]
      when 'qiita'
        new(
          provider: auth[:provider],
          avatar: auth[:info][:image],
          uid: auth[:uid],
          username: normalize_username(auth[:uid]),
          token: auth[:credentials][:token],
        )
      else
        fail UnsupportedProviderError
      end
    end

    private

    def normalize_username(username)
      username.to_s.downcase.tr('-', '_').gsub('@github', '').remove(/[^a-z0-9_]/i)
    end
  end

  def save
    return false if invalid?

    ApplicationRecord.transaction do
      self.user = build_user
      oauth_authentication = build_authorization(user)
      user.save! && oauth_authentication.save!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def validate_user
    user = build_user
    user.valid?

    [user, user.account].each do |record|
      record.errors.each do |key, value|
        errors.add(key, value) if respond_to?(key)
      end
    end
  end

  def build_user
    password = SecureRandom.base64

    User.new(
      email: email,
      locale: locale,
      password: password,
      password_confirmation: password,
      account_attributes: {
        username: username,
        avatar: avatar
      },
    )
  end

  def build_authorization(user)
    case provider
    when 'qiita'
      QiitaAuthorization.new(
        uid: uid,
        user: user,
        token: token,
      )
    else
      fail UnsupportedProviderError
    end
  end
end
