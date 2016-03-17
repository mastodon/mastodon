class Account < ActiveRecord::Base
  # Local users
  has_one :user, inverse_of: :account
  validates :username, uniqueness: { scope: :domain, case_sensitive: false }, if:     'local?'
  validates :username, uniqueness: { scope: :domain, case_sensitive: true },  unless: 'local?'

  # Avatar upload
  attr_reader :avatar_remote_url
  has_attached_file :avatar, styles: { large: '300x300#', medium: '96x96#', small: '48x48#' }, default_url: 'avatars/missing.png'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # Header upload
  has_attached_file :header, styles: { medium: '700x335#' }
  validates_attachment_content_type :header, content_type: /\Aimage\/.*\Z/

  # Local user profile validations
  validates :display_name, length: { maximum: 30 }, if: 'local?'
  validates :note, length: { maximum: 124 }, if: 'local?'

  # Timelines
  has_many :stream_entries, inverse_of: :account
  has_many :statuses, inverse_of: :account
  has_many :favourites, inverse_of: :account
  has_many :mentions, inverse_of: :account

  # Follow relations
  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'account_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_account_id', dependent: :destroy

  has_many :following, through: :active_relationships,  source: :target_account
  has_many :followers, through: :passive_relationships, source: :account

  MENTION_RE = /(?:^|\W)@([a-z0-9_]+(?:@[a-z0-9\.\-]+)?)/i

  def follow!(other_account)
    self.active_relationships.where(target_account: other_account).first_or_create!(target_account: other_account)
  end

  def unfollow!(other_account)
    follow = self.active_relationships.find_by(target_account: other_account)
    follow.destroy unless follow.nil?
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

  def favourited?(status)
    (status.reblog? ? status.reblog : status).favourites.where(account: self).count == 1
  end

  def reblogged?(status)
    (status.reblog? ? status.reblog : status).reblogs.where(account: self).count == 1
  end

  def keypair
    self.private_key.nil? ? OpenSSL::PKey::RSA.new(self.public_key) : OpenSSL::PKey::RSA.new(self.private_key)
  end

  def subscription(webhook_url)
    @subscription ||= OStatus2::Subscription.new(self.remote_url, secret: self.secret, token: self.verify_token, webhook: webhook_url, hub: self.hub_url)
  end

  def ping!(atom_url, hubs)
    return unless local?
    OStatus2::Publication.new(atom_url, hubs).publish
  end

  def avatar_remote_url=(url)
    self.avatar = URI.parse(url)
    @avatar_remote_url = url
  end

  def to_param
    self.username
  end

  def self.find_local!(username)
    table = self.arel_table
    self.where(table[:username].matches(username)).where(domain: nil).take!
  end

  before_create do
    if local?
      keypair = OpenSSL::PKey::RSA.new(Rails.env.test? ? 1024 : 2048)
      self.private_key = keypair.to_pem
      self.public_key  = keypair.public_key.to_pem
    end
  end
end
