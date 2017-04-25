# frozen_string_literal: true

class Account < ApplicationRecord
  include Targetable

  MENTION_RE = /(?:^|[^\/\w])@([a-z0-9_]+(?:@[a-z0-9\.\-]+[a-z0-9]+)?)/i
  IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

  # Local users
  has_one :user, inverse_of: :account
  validates :username, presence: true, format: { with: /\A[a-z0-9_]+\z/i }, uniqueness: { scope: :domain, case_sensitive: false }, length: { maximum: 30 }, if: 'local?'
  validates :username, presence: true, uniqueness: { scope: :domain, case_sensitive: true }, unless: 'local?'

  # Avatar upload
  has_attached_file :avatar, styles: ->(f) { avatar_styles(f) }, convert_options: { all: '-quality 80 -strip' }
  validates_attachment_content_type :avatar, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :avatar, less_than: 2.megabytes

  # Header upload
  has_attached_file :header, styles: ->(f) { header_styles(f) }, convert_options: { all: '-quality 80 -strip' }
  validates_attachment_content_type :header, content_type: IMAGE_MIME_TYPES
  validates_attachment_size :header, less_than: 2.megabytes

  before_post_process :set_file_extensions

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
  has_many :follow_requests, dependent: :destroy

  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'account_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_account_id', dependent: :destroy

  has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_account
  has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :account

  # Block relationships
  has_many :block_relationships, class_name: 'Block', foreign_key: 'account_id', dependent: :destroy
  has_many :blocking, -> { order('blocks.id desc') }, through: :block_relationships, source: :target_account

  # Mute relationships
  has_many :mute_relationships, class_name: 'Mute', foreign_key: 'account_id', dependent: :destroy
  has_many :muting, -> { order('mutes.id desc') }, through: :mute_relationships, source: :target_account

  # Media
  has_many :media_attachments, dependent: :destroy

  # PuSH subscriptions
  has_many :subscriptions, dependent: :destroy

  # Report relationships
  has_many :reports
  has_many :targeted_reports, class_name: 'Report', foreign_key: :target_account_id

  scope :remote, -> { where.not(domain: nil) }
  scope :local, -> { where(domain: nil) }
  scope :without_followers, -> { where('(select count(f.id) from follows as f where f.target_account_id = accounts.id) = 0') }
  scope :with_followers, -> { where('(select count(f.id) from follows as f where f.target_account_id = accounts.id) > 0') }
  scope :expiring, ->(time) { where(subscription_expires_at: nil).or(where('subscription_expires_at < ?', time)).remote.with_followers }
  scope :silenced, -> { where(silenced: true) }
  scope :suspended, -> { where(suspended: true) }
  scope :recent, -> { reorder(id: :desc) }
  scope :alphabetic, -> { order(domain: :asc, username: :asc) }
  scope :by_domain_accounts, -> { group(:domain).select(:domain, 'COUNT(*) AS accounts_count').order('accounts_count desc') }

  def follow!(other_account)
    active_relationships.where(target_account: other_account).first_or_create!(target_account: other_account)
  end

  def block!(other_account)
    block_relationships.where(target_account: other_account).first_or_create!(target_account: other_account)
  end

  def mute!(other_account)
    mute_relationships.where(target_account: other_account).first_or_create!(target_account: other_account)
  end

  def unfollow!(other_account)
    follow = active_relationships.find_by(target_account: other_account)
    follow&.destroy
  end

  def unblock!(other_account)
    block = block_relationships.find_by(target_account: other_account)
    block&.destroy
  end

  def unmute!(other_account)
    mute = mute_relationships.find_by(target_account: other_account)
    mute&.destroy
  end

  def following?(other_account)
    following.include?(other_account)
  end

  def blocking?(other_account)
    blocking.include?(other_account)
  end

  def muting?(other_account)
    muting.include?(other_account)
  end

  def requested?(other_account)
    follow_requests.where(target_account: other_account).exists?
  end

  def local?
    domain.nil?
  end

  def acct
    local? ? username : "#{username}@#{domain}"
  end

  def local_username_and_domain
    "#{username}@#{Rails.configuration.x.local_domain}"
  end

  def to_webfinger_s
    "acct:#{local_username_and_domain}"
  end

  def subscribed?
    !subscription_expires_at.blank?
  end

  def followers_domains
    followers.reorder(nil).pluck('distinct accounts.domain')
  end

  def favourited?(status)
    status.proper.favourites.where(account: self).count.positive?
  end

  def reblogged?(status)
    status.proper.reblogs.where(account: self).count.positive?
  end

  def keypair
    private_key.nil? ? OpenSSL::PKey::RSA.new(public_key) : OpenSSL::PKey::RSA.new(private_key)
  end

  def subscription(webhook_url)
    OStatus2::Subscription.new(remote_url, secret: secret, lease_seconds: 86_400 * 30, webhook: webhook_url, hub: hub_url)
  end

  def save_with_optional_avatar!
    save!
  rescue ActiveRecord::RecordInvalid
    self.avatar              = nil
    self.header              = nil
    self[:avatar_remote_url] = ''
    self[:header_remote_url] = ''
    save!
  end

  def avatar_original_url
    avatar.url(:original)
  end

  def avatar_static_url
    avatar_content_type == 'image/gif' ? avatar.url(:static) : avatar_original_url
  end

  def header_original_url
    header.url(:original)
  end

  def header_static_url
    header_content_type == 'image/gif' ? header.url(:static) : header_original_url
  end

  def avatar_remote_url=(url)
    parsed_url = Addressable::URI.parse(url).normalize

    return if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.empty? || self[:avatar_remote_url] == url

    self.avatar              = URI.parse(parsed_url.to_s)
    self[:avatar_remote_url] = url
  rescue OpenURI::HTTPError => e
    Rails.logger.debug "Error fetching remote avatar: #{e}"
  end

  def header_remote_url=(url)
    parsed_url = Addressable::URI.parse(url).normalize

    return if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.empty? || self[:header_remote_url] == url

    self.header              = URI.parse(parsed_url.to_s)
    self[:header_remote_url] = url
  rescue OpenURI::HTTPError => e
    Rails.logger.debug "Error fetching remote header: #{e}"
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
      return if username.blank?
      where('lower(accounts.username) = ?', username.downcase).where(domain.nil? ? { domain: nil } : 'lower(accounts.domain) = ?', domain&.downcase).take!
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

    def triadic_closures(account, limit = 5)
      sql = <<-SQL.squish
        WITH first_degree AS (
            SELECT target_account_id
            FROM follows
            WHERE account_id = :account_id
          )
        SELECT accounts.*
        FROM follows
        INNER JOIN accounts ON follows.target_account_id = accounts.id
        WHERE account_id IN (SELECT * FROM first_degree) AND target_account_id NOT IN (SELECT * FROM first_degree) AND target_account_id <> :account_id
        GROUP BY target_account_id, accounts.id
        ORDER BY count(account_id) DESC
        LIMIT :limit
      SQL

      find_by_sql(
        [sql, { account_id: account.id, limit: limit }]
      )
    end

    def search_for(terms, limit = 10)
      terms      = Arel.sql(connection.quote(terms.gsub(/['?\\:]/, ' ')))
      textsearch = '(setweight(to_tsvector(\'simple\', accounts.display_name), \'A\') || setweight(to_tsvector(\'simple\', accounts.username), \'B\') || setweight(to_tsvector(\'simple\', coalesce(accounts.domain, \'\')), \'C\'))'
      query      = 'to_tsquery(\'simple\', \'\'\' \' || ' + terms + ' || \' \'\'\' || \':*\')'

      sql = <<-SQL.squish
        SELECT
          accounts.*,
          ts_rank_cd(#{textsearch}, #{query}, 32) AS rank
        FROM accounts
        WHERE #{query} @@ #{textsearch}
        ORDER BY rank DESC
        LIMIT ?
      SQL

      Account.find_by_sql([sql, limit])
    end

    def advanced_search_for(terms, account, limit = 10)
      terms      = Arel.sql(connection.quote(terms.gsub(/['?\\:]/, ' ')))
      textsearch = '(setweight(to_tsvector(\'simple\', accounts.display_name), \'A\') || setweight(to_tsvector(\'simple\', accounts.username), \'B\') || setweight(to_tsvector(\'simple\', coalesce(accounts.domain, \'\')), \'C\'))'
      query      = 'to_tsquery(\'simple\', \'\'\' \' || ' + terms + ' || \' \'\'\' || \':*\')'

      sql = <<-SQL.squish
        SELECT
          accounts.*,
          (count(f.id) + 1) * ts_rank_cd(#{textsearch}, #{query}, 32) AS rank
        FROM accounts
        LEFT OUTER JOIN follows AS f ON (accounts.id = f.account_id AND f.target_account_id = ?) OR (accounts.id = f.target_account_id AND f.account_id = ?)
        WHERE #{query} @@ #{textsearch}
        GROUP BY accounts.id
        ORDER BY rank DESC
        LIMIT ?
      SQL

      Account.find_by_sql([sql, account.id, account.id, limit])
    end

    def following_map(target_account_ids, account_id)
      follow_mapping(Follow.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end

    def followed_by_map(target_account_ids, account_id)
      follow_mapping(Follow.where(account_id: target_account_ids, target_account_id: account_id), :account_id)
    end

    def blocking_map(target_account_ids, account_id)
      follow_mapping(Block.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end

    def muting_map(target_account_ids, account_id)
      follow_mapping(Mute.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end

    def requested_map(target_account_ids, account_id)
      follow_mapping(FollowRequest.where(target_account_id: target_account_ids, account_id: account_id), :target_account_id)
    end

    private

    def follow_mapping(query, field)
      query.pluck(field).inject({}) { |mapping, id| mapping[id] = true; mapping }
    end

    def avatar_styles(file)
      styles = { original: '120x120#' }
      styles[:static] = { format: 'png' } if file.content_type == 'image/gif'
      styles
    end

    def header_styles(file)
      styles = { original: '700x335#' }
      styles[:static] = { format: 'png' } if file.content_type == 'image/gif'
      styles
    end
  end

  before_create :generate_keys
  before_validation :normalize_domain

  private

  def generate_keys
    return unless local?

    keypair = OpenSSL::PKey::RSA.new(Rails.env.test? ? 1024 : 2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end

  def normalize_domain
    return if local?

    self.domain = TagManager.instance.normalize_domain(domain)
  end

  def set_file_extensions
    unless avatar.blank?
      extension = Paperclip::Interpolations.content_type_extension(avatar, :original)
      basename  = Paperclip::Interpolations.basename(avatar, :original)
      avatar.instance_write :file_name, [basename, extension].delete_if(&:empty?).join('.')
    end

    unless header.blank?
      extension = Paperclip::Interpolations.content_type_extension(header, :original)
      basename  = Paperclip::Interpolations.basename(header, :original)
      header.instance_write :file_name, [basename, extension].delete_if(&:empty?).join('.')
    end
  end
end
