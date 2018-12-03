# frozen_string_literal: true
# == Schema Information
#
# Table name: accounts
#
#  id                      :bigint(8)        not null, primary key
#  username                :string           default(""), not null
#  domain                  :string
#  secret                  :string           default(""), not null
#  private_key             :text
#  public_key              :text             default(""), not null
#  remote_url              :string           default(""), not null
#  salmon_url              :string           default(""), not null
#  hub_url                 :string           default(""), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  note                    :text             default(""), not null
#  display_name            :string           default(""), not null
#  uri                     :string           default(""), not null
#  url                     :string
#  avatar_file_name        :string
#  avatar_content_type     :string
#  avatar_file_size        :integer
#  avatar_updated_at       :datetime
#  header_file_name        :string
#  header_content_type     :string
#  header_file_size        :integer
#  header_updated_at       :datetime
#  avatar_remote_url       :string
#  subscription_expires_at :datetime
#  silenced                :boolean          default(FALSE), not null
#  suspended               :boolean          default(FALSE), not null
#  locked                  :boolean          default(FALSE), not null
#  header_remote_url       :string           default(""), not null
#  last_webfingered_at     :datetime
#  inbox_url               :string           default(""), not null
#  outbox_url              :string           default(""), not null
#  shared_inbox_url        :string           default(""), not null
#  followers_url           :string           default(""), not null
#  protocol                :integer          default("ostatus"), not null
#  memorial                :boolean          default(FALSE), not null
#  moved_to_account_id     :bigint(8)
#  featured_collection_url :string
#  fields                  :jsonb
#  actor_type              :string
#

class Account < ApplicationRecord
  USERNAME_RE = /[a-z0-9_]+([a-z0-9_\.-]+[a-z0-9_]+)?/i
  MENTION_RE  = /(?<=^|[^\/[:word:]])@((#{USERNAME_RE})(?:@[a-z0-9\.\-]+[a-z0-9]+)?)/i

  include AccountAssociations
  include AccountAvatar
  include AccountFinderConcern
  include AccountHeader
  include AccountInteractions
  include Attachmentable
  include Paginable
  include AccountCounters

  enum protocol: [:ostatus, :activitypub]

  validates :username, presence: true

  # Remote user validations
  validates :username, uniqueness: { scope: :domain, case_sensitive: true }, if: -> { !local? && will_save_change_to_username? }
  validates :username, format: { with: /\A#{USERNAME_RE}\z/i }, if: -> { !local? && will_save_change_to_username? }

  # Local user validations
  validates :username, format: { with: /\A[a-z0-9_]+\z/i }, length: { maximum: 30 }, if: -> { local? && will_save_change_to_username? }
  validates_with UniqueUsernameValidator, if: -> { local? && will_save_change_to_username? }
  validates_with UnreservedUsernameValidator, if: -> { local? && will_save_change_to_username? }
  validates :display_name, length: { maximum: 30 }, if: -> { local? && will_save_change_to_display_name? }
  validates :note, length: { maximum: 160 }, if: -> { local? && will_save_change_to_note? }
  validates :fields, length: { maximum: 4 }, if: -> { local? && will_save_change_to_fields? }

  scope :remote, -> { where.not(domain: nil) }
  scope :local, -> { where(domain: nil) }
  scope :expiring, ->(time) { remote.where.not(subscription_expires_at: nil).where('subscription_expires_at < ?', time) }
  scope :partitioned, -> { order(Arel.sql('row_number() over (partition by domain)')) }
  scope :silenced, -> { where(silenced: true) }
  scope :suspended, -> { where(suspended: true) }
  scope :without_suspended, -> { where(suspended: false) }
  scope :recent, -> { reorder(id: :desc) }
  scope :bots, -> { where(actor_type: %w(Application Service)) }
  scope :alphabetic, -> { order(domain: :asc, username: :asc) }
  scope :by_domain_accounts, -> { group(:domain).select(:domain, 'COUNT(*) AS accounts_count').order('accounts_count desc') }
  scope :matches_username, ->(value) { where(arel_table[:username].matches("#{value}%")) }
  scope :matches_display_name, ->(value) { where(arel_table[:display_name].matches("#{value}%")) }
  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }
  scope :searchable, -> { where(suspended: false).where(moved_to_account_id: nil) }

  delegate :email,
           :unconfirmed_email,
           :current_sign_in_ip,
           :current_sign_in_at,
           :confirmed?,
           :admin?,
           :moderator?,
           :staff?,
           :locale,
           :hides_network?,
           to: :user,
           prefix: true,
           allow_nil: true

  delegate :chosen_languages, to: :user, prefix: false, allow_nil: true

  def local?
    domain.nil?
  end

  def moved?
    moved_to_account_id.present?
  end

  def bot?
    %w(Application Service).include? actor_type
  end

  alias bot bot?

  def bot=(val)
    self.actor_type = ActiveModel::Type::Boolean.new.cast(val) ? 'Service' : 'Person'
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
    subscription_expires_at.present?
  end

  def possibly_stale?
    last_webfingered_at.nil? || last_webfingered_at <= 1.day.ago
  end

  def refresh!
    return if local?
    ResolveAccountService.new.call(acct)
  end

  def suspend!
    transaction do
      user&.disable! if local?
      update!(suspended: true)
    end
  end

  def unsuspend!
    transaction do
      user&.enable! if local?
      update!(suspended: false)
    end
  end

  def memorialize!
    transaction do
      user&.disable! if local?
      update!(memorial: true)
    end
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(private_key || public_key)
  end

  def fields
    (self[:fields] || []).map { |f| Field.new(self, f) }
  end

  def fields_attributes=(attributes)
    fields     = []
    old_fields = self[:fields] || []

    if attributes.is_a?(Hash)
      attributes.each_value do |attr|
        next if attr[:name].blank?

        previous = old_fields.find { |item| item['value'] == attr[:value] }

        if previous && previous['verified_at'].present?
          attr[:verified_at] = previous['verified_at']
        end

        fields << attr
      end
    end

    self[:fields] = fields
  end

  DEFAULT_FIELDS_SIZE = 4

  def build_fields
    return if fields.size >= DEFAULT_FIELDS_SIZE

    tmp = self[:fields] || []

    (DEFAULT_FIELDS_SIZE - tmp.size).times do
      tmp << { name: '', value: '' }
    end

    self.fields = tmp
  end

  def magic_key
    modulus, exponent = [keypair.public_key.n, keypair.public_key.e].map do |component|
      result = []

      until component.zero?
        result << [component % 256].pack('C')
        component >>= 8
      end

      result.reverse.join
    end

    (['RSA'] + [modulus, exponent].map { |n| Base64.urlsafe_encode64(n) }).join('.')
  end

  def subscription(webhook_url)
    @subscription ||= OStatus2::Subscription.new(remote_url, secret: secret, webhook: webhook_url, hub: hub_url)
  end

  def save_with_optional_media!
    save!
  rescue ActiveRecord::RecordInvalid
    self.avatar              = nil
    self.header              = nil
    self[:avatar_remote_url] = ''
    self[:header_remote_url] = ''
    save!
  end

  def object_type
    :person
  end

  def to_param
    username
  end

  def excluded_from_timeline_account_ids
    Rails.cache.fetch("exclude_account_ids_for:#{id}") { blocking.pluck(:target_account_id) + blocked_by.pluck(:account_id) + muting.pluck(:target_account_id) }
  end

  def excluded_from_timeline_domains
    Rails.cache.fetch("exclude_domains_for:#{id}") { domain_blocks.pluck(:domain) }
  end

  def preferred_inbox_url
    shared_inbox_url.presence || inbox_url
  end

  class Field < ActiveModelSerializers::Model
    attributes :name, :value, :verified_at, :account, :errors

    def initialize(account, attributes)
      @account     = account
      @attributes  = attributes
      @name        = attributes['name'].strip[0, string_limit]
      @value       = attributes['value'].strip[0, string_limit]
      @verified_at = attributes['verified_at']&.to_datetime
      @errors      = {}
    end

    def verified?
      verified_at.present?
    end

    def value_for_verification
      @value_for_verification ||= begin
        if account.local?
          value
        else
          ActionController::Base.helpers.strip_tags(value)
        end
      end
    end

    def verifiable?
      value_for_verification.present? && value_for_verification.start_with?('http://', 'https://')
    end

    def mark_verified!
      @verified_at = Time.now.utc
      @attributes['verified_at'] = @verified_at
    end

    def to_h
      { name: @name, value: @value, verified_at: @verified_at }
    end

    private

    def string_limit
      if account.local?
        255
      else
        2047
      end
    end
  end

  class << self
    def readonly_attributes
      super - %w(statuses_count following_count followers_count)
    end

    def domains
      reorder(nil).pluck(Arel.sql('distinct accounts.domain'))
    end

    def inboxes
      urls = reorder(nil).where(protocol: :activitypub).pluck(Arel.sql("distinct coalesce(nullif(accounts.shared_inbox_url, ''), accounts.inbox_url)"))
      DeliveryFailureTracker.filter(urls)
    end

    def search_for(terms, limit = 10)
      textsearch, query = generate_query_for_search(terms)

      sql = <<-SQL.squish
        SELECT
          accounts.*,
          ts_rank_cd(#{textsearch}, #{query}, 32) AS rank
        FROM accounts
        WHERE #{query} @@ #{textsearch}
          AND accounts.suspended = false
          AND accounts.moved_to_account_id IS NULL
        ORDER BY rank DESC
        LIMIT ?
      SQL

      records = find_by_sql([sql, limit])
      ActiveRecord::Associations::Preloader.new.preload(records, :account_stat)
      records
    end

    def advanced_search_for(terms, account, limit = 10, following = false)
      textsearch, query = generate_query_for_search(terms)

      if following
        sql = <<-SQL.squish
          WITH first_degree AS (
            SELECT target_account_id
            FROM follows
            WHERE account_id = ?
          )
          SELECT
            accounts.*,
            (count(f.id) + 1) * ts_rank_cd(#{textsearch}, #{query}, 32) AS rank
          FROM accounts
          LEFT OUTER JOIN follows AS f ON (accounts.id = f.account_id AND f.target_account_id = ?) OR (accounts.id = f.target_account_id AND f.account_id = ?)
          WHERE accounts.id IN (SELECT * FROM first_degree)
            AND #{query} @@ #{textsearch}
            AND accounts.suspended = false
            AND accounts.moved_to_account_id IS NULL
          GROUP BY accounts.id
          ORDER BY rank DESC
          LIMIT ?
        SQL

        records = find_by_sql([sql, account.id, account.id, account.id, limit])
      else
        sql = <<-SQL.squish
          SELECT
            accounts.*,
            (count(f.id) + 1) * ts_rank_cd(#{textsearch}, #{query}, 32) AS rank
          FROM accounts
          LEFT OUTER JOIN follows AS f ON (accounts.id = f.account_id AND f.target_account_id = ?) OR (accounts.id = f.target_account_id AND f.account_id = ?)
          WHERE #{query} @@ #{textsearch}
            AND accounts.suspended = false
            AND accounts.moved_to_account_id IS NULL
          GROUP BY accounts.id
          ORDER BY rank DESC
          LIMIT ?
        SQL

        records = find_by_sql([sql, account.id, account.id, limit])
      end

      ActiveRecord::Associations::Preloader.new.preload(records, :account_stat)
      records
    end

    private

    def generate_query_for_search(terms)
      terms      = Arel.sql(connection.quote(terms.gsub(/['?\\:]/, ' ')))
      textsearch = "(setweight(to_tsvector('simple', accounts.display_name), 'A') || setweight(to_tsvector('simple', accounts.username), 'B') || setweight(to_tsvector('simple', coalesce(accounts.domain, '')), 'C'))"
      query      = "to_tsquery('simple', ''' ' || #{terms} || ' ''' || ':*')"

      [textsearch, query]
    end
  end

  def emojis
    @emojis ||= CustomEmoji.from_text(emojifiable_text, domain)
  end

  before_create :generate_keys
  before_validation :normalize_domain
  before_validation :prepare_contents, if: :local?
  before_destroy :clean_feed_manager

  private

  def prepare_contents
    display_name&.strip!
    note&.strip!
  end

  def generate_keys
    return unless local? && !Rails.env.test?

    keypair = OpenSSL::PKey::RSA.new(2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end

  def normalize_domain
    return if local?

    self.domain = TagManager.instance.normalize_domain(domain)
  end

  def emojifiable_text
    [note, display_name, fields.map(&:value)].join(' ')
  end

  def clean_feed_manager
    reblog_key       = FeedManager.instance.key(:home, id, 'reblogs')
    reblogged_id_set = Redis.current.zrange(reblog_key, 0, -1)

    Redis.current.pipelined do
      Redis.current.del(FeedManager.instance.key(:home, id))
      Redis.current.del(reblog_key)

      reblogged_id_set.each do |reblogged_id|
        reblog_set_key = FeedManager.instance.key(:home, id, "reblogs:#{reblogged_id}")
        Redis.current.del(reblog_set_key)
      end
    end
  end
end
