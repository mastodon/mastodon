class Account < ActiveRecord::Base
  # Local users
  has_one :user, inverse_of: :account

  # Timelines
  has_many :stream_entries, inverse_of: :account
  has_many :statuses, inverse_of: :account
  has_many :favourites, inverse_of: :account

  # Follow relations
  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'account_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_account_id', dependent: :destroy

  has_many :following, through: :active_relationships,  source: :target_account
  has_many :followers, through: :passive_relationships, source: :account

  MENTION_RE = /(?:^|\W)@([a-z0-9_]+(?:@[a-z0-9\.\-]+)?)/i

  def follow!(other_account)
    self.active_relationships.first_or_create!(target_account: other_account)
  end

  def unfollow!(other_account)
    self.active_relationships.find_by(target_account: other_account).destroy
  end

  def following?(other_account)
    following.include?(other_account)
  end

  def local?
    self.domain.nil?
  end

  def acct
    local? ? self.username : "#{self.username}@#{self.domain}"
  end

  def object_type
    :person
  end

  def title
    self.username
  end

  def content
    self.note
  end

  def subscribed?
    !(self.secret.blank? || self.verify_token.blank?)
  end

  def keypair
    self.private_key.nil? ? OpenSSL::PKey::RSA.new(self.public_key) : OpenSSL::PKey::RSA.new(self.private_key)
  end

  def subscription(webhook_url)
    @subscription ||= OStatus2::Subscription.new(self.remote_url, secret: self.secret, token: self.verify_token, webhook: webhook_url, hub: self.hub_url)
  end

  before_create do
    if local?
      keypair = OpenSSL::PKey::RSA.new(Rails.env.test? ? 48 : 2048)
      self.private_key = keypair.to_pem
      self.public_key  = keypair.public_key.to_pem
    end
  end
end
