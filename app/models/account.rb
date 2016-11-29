# frozen_string_literal: true

class Account < ApplicationRecord
  include Targetable
  include PgSearch

  MENTION_RE = /(?:^|[^\/\w])@([a-z0-9_]+(?:@[a-z0-9\.\-]+)?)/i
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  # Local users
  has_one :user, inverse_of: :account
  validates :username, presence: true, format: { with: /\A[a-z0-9_]+\z/i, message: 'only letters, numbers and underscores' }, uniqueness: { scope: :domain, case_sensitive: false }, length: { maximum: 30 }, if: 'local?'
  validates :username, presence: true, uniqueness: { scope: :domain, case_sensitive: true }, unless: 'local?'

  # Avatar upload
  has_attached_file :avatar, styles: { large: '300x300#', medium: '96x96#', small: '48x48#' }
  validates_attachment_content_type :avatar, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :avatar, less_than: 2.megabytes

  # Header upload
  has_attached_file :header, styles: { medium: '700x335#' }
  validates_attachment_content_type :header, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :header, less_than: 2.megabytes

  # Local user profile validations
  validates :display_name, length: { maximum: 30 }, if: 'local?'
  validates :note, length: { maximum: 160 }, if: 'local?'

  # Timelines
  has_many :stream_entries, inverse_of: :account, dependent: :destroy
  has_many :statuses, inverse_of: :account, dependent: :destroy
  has_many :favourites, inverse_of: :account, dependent: :destroy
  has_many :mentions, inverse_of: :account, dependent: :destroy
  has_many :notifications, inverse_of: :account, dependent: :destroy

  # Follow relations
  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'account_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_account_id', dependent: :destroy

  has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_account
  has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :account

  # Block relationships
  has_many :block_relationships, class_name: 'Block', foreign_key: 'account_id', dependent: :destroy
  has_many :blocking, -> { order('blocks.id desc') }, through: :block_relationships, source: :target_account

  # Media
  has_many :media_attachments, dependent: :destroy

  # PuSH subscriptions
  has_many :subscriptions, dependent: :destroy

  pg_search_scope :search_for, against: { username: 'A', domain: 'B' }, using: { tsearch: { prefix: true } }

  scope :remote, -> { where.not(domain: nil) }
  scope :local, -> { where(domain: nil) }
  scope :without_followers, -> { where('(select count(f.id) from follows as f where f.target_account_id = accounts.id) = 0') }
  scope :with_followers, -> { where('(select count(f.id) from follows as f where f.target_account_id = accounts.id) > 0') }
  scope :expiring, -> (time) { where(subscription_expires_at: nil).or(where('subscription_expires_at < ?', time)).remote.with_followers }

  scope :with_counters, -> { select('accounts.*, (select count(f.id) from follows as f where f.target_account_id = accounts.id) as followers_count, (select count(f.id) from follows as f where f.account_id = accounts.id) as following_count, (select count(s.id) from statuses as s where s.account_id = accounts.id) as statuses_count') }

  def follow!(other_account)
    active_relationships.where(target_account: other_account).first_or_create!(target_account: other_account)
  end

  def block!(other_account)
    block_relationships.where(target_account: other_account).first_or_create!(target_account: other_account)
  end

  def unfollow!(other_account)
    follow = active_relationships.find_by(target_account: other_account)
    follow&.destroy
  end

  def unblock!(other_account)
    block = block_relationships.find_by(target_account: other_account)
    block&.destroy
  end

  def following?(other_account)
    following.include?(other_account)
  end

  def blocking?(other_account)
    blocking.include?(other_account)
  end

  def local?
    domain.nil?
  end

  def acct
    local? ? username : "#{username}@#{domain}"
  end

  def subscribed?
    !subscription_expires_at.nil?
  end

  def favourited?(status)
    (status.reblog? ? status.reblog : status).favourites.where(account: self).count.positive?
  end

  def reblogged?(status)
    (status.reblog? ? status.reblog : status).reblogs.where(account: self).count.positive?
  end

  def keypair
    private_key.nil? ? OpenSSL::PKey::RSA.new(public_key) : OpenSSL::PKey::RSA.new(private_key)
  end

  def subscription(webhook_url)
    OStatus2::Subscription.new(remote_url, secret: secret, lease_seconds: 86_400 * 30, webhook: webhook_url, hub: hub_url)
  end

  def ping!(atom_url, hubs)
    return unless local? && !Rails.env.development?
    OStatus2::Publication.new(atom_url, hubs).publish
  end

  def avatar_remote_url=(url)
    parsed_url = URI.parse(url)

    return if !%w(http https).include?(parsed_url.scheme) || self[:avatar_remote_url] == url

    self.avatar              = parsed_url
    self[:avatar_remote_url] = url
  rescue OpenURI::HTTPError => e
    Rails.logger.debug "Error fetching remote avatar: #{e}"
  end

  def object_type
    :person
  end

  def to_param
    username
  end

  class << self
    def find_local!(username)
      find_remote!(username, nil)
    end

    def find_remote!(username, domain)
      where(arel_table[:username].matches(username.gsub(/[%_]/, '\\\\\0'))).where(domain.nil? ? { domain: nil } : arel_table[:domain].matches(domain.gsub(/[%_]/, '\\\\\0'))).take!
    end

    def find_local(username)
      find_local!(username)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def find_remote(username, domain)
      find_remote!(username, domain)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def following_map(target_account_ids, account_id)
      Follow.where(target_account_id: target_account_ids).where(account_id: account_id).map { |f| [f.target_account_id, true] }.to_h
    end

    def followed_by_map(target_account_ids, account_id)
      Follow.where(account_id: target_account_ids).where(target_account_id: account_id).map { |f| [f.account_id, true] }.to_h
    end

    def blocking_map(target_account_ids, account_id)
      Block.where(target_account_id: target_account_ids).where(account_id: account_id).map { |b| [b.target_account_id, true] }.to_h
    end
  end

  before_create do
    if local?
      keypair = OpenSSL::PKey::RSA.new(Rails.env.test? ? 1024 : 2048)
      self.private_key = keypair.to_pem
      self.public_key  = keypair.public_key.to_pem
    end
  end
end
