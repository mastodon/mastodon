# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                            :bigint(8)        not null, primary key
#  actor_type                    :string
#  also_known_as                 :string           is an Array
#  attribution_domains           :string           default([]), is an Array
#  avatar_content_type           :string
#  avatar_description            :string           default(""), not null
#  avatar_file_name              :string
#  avatar_file_size              :integer
#  avatar_remote_url             :string
#  avatar_storage_schema_version :integer
#  avatar_updated_at             :datetime
#  discoverable                  :boolean
#  display_name                  :string           default(""), not null
#  domain                        :string
#  feature_approval_policy       :integer          default(0), not null
#  featured_collection_url       :string
#  fields                        :jsonb
#  followers_url                 :string           default(""), not null
#  following_url                 :string           default(""), not null
#  header_content_type           :string
#  header_description            :string           default(""), not null
#  header_file_name              :string
#  header_file_size              :integer
#  header_remote_url             :string           default(""), not null
#  header_storage_schema_version :integer
#  header_updated_at             :datetime
#  hide_collections              :boolean
#  id_scheme                     :integer          default("numeric_ap_id")
#  inbox_url                     :string           default(""), not null
#  indexable                     :boolean          default(FALSE), not null
#  last_webfingered_at           :datetime
#  locked                        :boolean          default(FALSE), not null
#  memorial                      :boolean          default(FALSE), not null
#  note                          :text             default(""), not null
#  outbox_url                    :string           default(""), not null
#  private_key                   :text
#  protocol                      :integer          default("ostatus"), not null
#  public_key                    :text             default(""), not null
#  requested_review_at           :datetime
#  reviewed_at                   :datetime
#  sensitized_at                 :datetime
#  shared_inbox_url              :string           default(""), not null
#  show_featured                 :boolean          default(TRUE), not null
#  show_media                    :boolean          default(TRUE), not null
#  show_media_replies            :boolean          default(TRUE), not null
#  silenced_at                   :datetime
#  suspended_at                  :datetime
#  suspension_origin             :integer
#  trendable                     :boolean
#  uri                           :string           default(""), not null
#  url                           :string
#  username                      :string           default(""), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  moved_to_account_id           :bigint(8)
#

class Account < ApplicationRecord
  self.ignored_columns += %w(
    devices_url
    hub_url
    remote_url
    salmon_url
    secret
    subscription_expires_at
    trust_level
  )

  BACKGROUND_REFRESH_INTERVAL = 1.week.freeze
  REFRESH_DEADLINE = 6.hours
  STALE_THRESHOLD = 1.day
  DEFAULT_FIELDS_SIZE = 4
  INSTANCE_ACTOR_ID = -99

  USERNAME_RE   = /[a-z0-9_]+([.-]+[a-z0-9_]+)*/i
  MENTION_RE    = %r{(?<![=/[:word:]])@((#{USERNAME_RE})(?:@[[:word:]]+([.-]+[[:word:]]+)*)?)}
  URL_PREFIX_RE = %r{\Ahttp(s?)://[^/]+}
  USERNAME_ONLY_RE = /\A#{USERNAME_RE}\z/i
  USERNAME_LENGTH_LIMIT = 30
  DISPLAY_NAME_LENGTH_LIMIT = 30
  NOTE_LENGTH_LIMIT = 500

  # Hard limits for federated content
  USERNAME_LENGTH_HARD_LIMIT = 2048
  DISPLAY_NAME_LENGTH_HARD_LIMIT = 2048
  NOTE_LENGTH_HARD_LIMIT = 20.kilobytes
  ATTRIBUTION_DOMAINS_HARD_LIMIT = 256
  ALSO_KNOWN_AS_HARD_LIMIT = 256

  AUTOMATED_ACTOR_TYPES = %w(Application Service).freeze

  include Attachmentable # Load prior to Avatar & Header concerns

  include Account::Associations
  include Account::Avatar
  include Account::Counters
  include Account::FaspConcern
  include Account::FinderConcern
  include Account::Header
  include Account::InteractionPolicyConcern
  include Account::Interactions
  include Account::Mappings
  include Account::Merging
  include Account::Search
  include Account::Sensitizes
  include Account::Silences
  include Account::StatusesSearch
  include Account::Suspensions
  include Account::AttributionDomains
  include DomainMaterializable
  include DomainNormalizable
  include Paginable
  include Reviewable

  enum :protocol, { ostatus: 0, activitypub: 1 }
  enum :suspension_origin, { local: 0, remote: 1 }, prefix: true
  enum :id_scheme, { username_ap_id: 0, numeric_ap_id: 1 }

  validates :username, presence: true
  validates_with UniqueUsernameValidator, if: -> { will_save_change_to_username? }

  # Remote user validations, also applies to internal actors
  validates :username, format: { with: USERNAME_ONLY_RE }, length: { maximum: USERNAME_LENGTH_HARD_LIMIT }, if: -> { (remote? || actor_type_application?) && will_save_change_to_username? }

  # Remote user validations
  validates :uri, presence: true, unless: :local?, on: :create

  # Local user validations
  validates :username, format: { with: /\A[a-z0-9_]+\z/i }, length: { maximum: USERNAME_LENGTH_LIMIT }, if: -> { local? && will_save_change_to_username? && !actor_type_application? }
  validates_with UnreservedUsernameValidator, if: -> { local? && will_save_change_to_username? && !actor_type_application? && !user&.bypass_registration_checks }
  validates :display_name, length: { maximum: DISPLAY_NAME_LENGTH_LIMIT }, if: -> { local? && will_save_change_to_display_name? }
  validates :note, note_length: { maximum: NOTE_LENGTH_LIMIT }, if: -> { local? && will_save_change_to_note? }
  validates :fields, length: { maximum: DEFAULT_FIELDS_SIZE }, if: -> { local? && will_save_change_to_fields? }
  validates_with EmptyProfileFieldNamesValidator, if: -> { local? && will_save_change_to_fields? }
  with_options on: :create, if: :local? do
    validates :followers_url, absence: true
    validates :following_url, absence: true
    validates :inbox_url, absence: true
    validates :shared_inbox_url, absence: true
    validates :uri, absence: true
  end

  validates :domain, exclusion: { in: [''] }

  normalizes :username, with: ->(username) { username.squish }

  scope :without_internal, -> { where(id: 1...) }
  scope :remote, -> { where.not(domain: nil) }
  scope :local, -> { where(domain: nil) }
  scope :partitioned, -> { order(Arel.sql('row_number() over (partition by domain)')) }
  scope :without_instance_actor, -> { where.not(id: INSTANCE_ACTOR_ID) }
  scope :recent, -> { reorder(id: :desc) }
  scope :non_automated, -> { where.not(actor_type: AUTOMATED_ACTOR_TYPES) }
  scope :matches_uri_prefix, ->(value) { where(arel_table[:uri].matches("#{sanitize_sql_like(value)}/%", false, true)).or(where(uri: value)) }
  scope :matches_username, ->(value) { where('lower((username)::text) LIKE lower(?)', "#{value}%") }
  scope :matches_display_name, ->(value) { where(arel_table[:display_name].matches("#{value}%")) }
  scope :without_unapproved, -> { left_outer_joins(:user).merge(User.approved.confirmed).or(remote) }
  scope :auditable, -> { where(id: Admin::ActionLog.select(:account_id).distinct) }
  scope :searchable, -> { without_unapproved.without_suspended.where(moved_to_account_id: nil) }
  scope :discoverable, -> { searchable.without_silenced.where(discoverable: true).joins(:account_stat) }
  scope :by_recent_status, -> { includes(:account_stat).merge(AccountStat.by_recent_status).references(:account_stat) }
  scope :by_recent_activity, -> { left_joins(:user, :account_stat).order(coalesced_activity_timestamps.desc).order(id: :desc) }
  scope :by_domain_and_subdomains, ->(domain) { where(domain: Instance.by_domain_and_subdomains(domain).select(:domain)) }
  scope :not_excluded_by_account, ->(account) { where.not(id: account.excluded_from_timeline_account_ids) }
  scope :not_domain_blocked_by_account, ->(account) { where(arel_table[:domain].eq(nil).or(arel_table[:domain].not_in(account.excluded_from_timeline_domains))) }
  scope :dormant, -> { joins(:account_stat).merge(AccountStat.without_recent_activity) }
  scope :with_username, ->(value) { value.is_a?(Array) ? where(arel_table[:username].lower.in(value.map { |x| x.to_s.downcase })) : where(arel_table[:username].lower.eq(value.to_s.downcase)) }
  scope :with_domain, ->(value) { where arel_table[:domain].lower.eq(value&.to_s&.downcase) }
  scope :without_memorial, -> { where(memorial: false) }
  scope :duplicate_uris, -> { select(:uri, Arel.star.count).group(:uri).having(Arel.star.count.gt(1)) }

  after_update_commit :trigger_update_webhooks

  delegate :email,
           :email_domain,
           :unconfirmed_email,
           :current_sign_in_at,
           :created_at,
           :sign_up_ip,
           :confirmed?,
           :approved?,
           :pending?,
           :disabled?,
           :unconfirmed?,
           :unconfirmed_or_pending?,
           :role,
           :locale,
           :shows_application?,
           :prefers_noindex?,
           :time_zone,
           to: :user,
           prefix: true,
           allow_nil: true

  delegate :chosen_languages, to: :user, prefix: false, allow_nil: true

  update_index('accounts', :self)

  def local?
    domain.nil?
  end

  def remote?
    !domain.nil?
  end

  def moved?
    moved_to_account_id.present?
  end

  def bot?
    AUTOMATED_ACTOR_TYPES.include?(actor_type)
  end

  def instance_actor?
    id == INSTANCE_ACTOR_ID
  end

  alias bot bot?

  def bot=(val)
    self.actor_type = ActiveModel::Type::Boolean.new.cast(val) ? 'Service' : 'Person'
  end

  def actor_type_application?
    actor_type == 'Application'
  end

  def group?
    actor_type == 'Group'
  end

  alias group group?

  def acct
    local? ? username : "#{username}@#{domain}"
  end

  def pretty_acct
    local? ? username : "#{username}@#{Addressable::IDNA.to_unicode(domain)}"
  end

  def local_username_and_domain
    "#{username}@#{Rails.configuration.x.local_domain}"
  end

  def local_followers_count
    Follow.where(target_account_id: id).count
  end

  def to_webfinger_s
    "acct:#{local_username_and_domain}"
  end

  def possibly_stale?
    last_webfingered_at.nil? || last_webfingered_at <= STALE_THRESHOLD.ago
  end

  def schedule_refresh_if_stale!
    return unless last_webfingered_at.present? && last_webfingered_at <= BACKGROUND_REFRESH_INTERVAL.ago

    AccountRefreshWorker.perform_in(rand(REFRESH_DEADLINE), id)
  end

  def refresh!
    ResolveAccountService.new.call(acct) unless local?
  end

  def memorialize!
    update!(memorial: true)
  end

  def trendable?
    boolean_with_default('trendable', Setting.trendable_by_default)
  end

  def sign?
    true
  end

  def previous_strikes_count
    strikes.where(overruled_at: nil).count
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(private_key || public_key)
  end

  def tags_as_strings=(tag_names)
    hashtags_map = Tag.find_or_create_by_names(tag_names).index_by(&:name)

    # Remove hashtags that are to be deleted
    tags.each do |tag|
      if hashtags_map.key?(tag.name)
        hashtags_map.delete(tag.name)
      else
        tags.delete(tag)
      end
    end

    # Add hashtags that were so far missing
    hashtags_map.each_value do |tag|
      tags << tag
    end
  end

  def also_known_as
    self[:also_known_as] || []
  end

  def fields
    (self[:fields] || []).filter_map do |f|
      Account::Field.new(self, f)
    rescue
      nil
    end
  end

  def fields_attributes=(attributes)
    fields     = []
    old_fields = self[:fields] || []
    old_fields = [] if old_fields.is_a?(Hash)

    if attributes.is_a?(Hash)
      attributes.each_value do |attr|
        next if attr[:name].blank? && attr[:value].blank?

        previous = old_fields.find { |item| item['value'] == attr[:value] }

        attr[:verified_at] = previous['verified_at'] if previous && previous['verified_at'].present?

        fields << attr
      end
    end

    self[:fields] = fields
  end

  def build_fields
    return if fields.size >= DEFAULT_FIELDS_SIZE

    tmp = self[:fields] || []
    tmp = [] if tmp.is_a?(Hash)

    (DEFAULT_FIELDS_SIZE - tmp.size).times do
      tmp << { name: '', value: '' }
    end

    self.fields = tmp
  end

  def save_with_optional_media!
    save!
  rescue ActiveRecord::RecordInvalid => e
    errors = e.record.errors.errors
    errors.each do |err|
      if err.attribute == :avatar
        self.avatar = nil
      elsif err.attribute == :header
        self.header = nil
      end
    end

    save!
  end

  def hides_followers?
    hide_collections?
  end

  def hides_following?
    hide_collections?
  end

  def object_type
    :person
  end

  def to_param
    username
  end

  def to_log_human_identifier
    acct
  end

  def excluded_from_timeline_account_ids
    Rails.cache.fetch("exclude_account_ids_for:#{id}") { block_relationships.pluck(:target_account_id) + blocked_by_relationships.pluck(:account_id) + mute_relationships.pluck(:target_account_id) }
  end

  def excluded_from_timeline_domains
    Rails.cache.fetch("exclude_domains_for:#{id}") { domain_blocks.pluck(:domain) }
  end

  def preferred_inbox_url
    shared_inbox_url.presence || inbox_url
  end

  def synchronization_uri_prefix
    return 'local' if local?

    @synchronization_uri_prefix ||= "#{uri[URL_PREFIX_RE]}/"
  end

  class << self
    def readonly_attributes
      super - %w(statuses_count following_count followers_count)
    end

    def inboxes
      urls = reorder(nil).activitypub.group(:preferred_inbox_url).pluck(Arel.sql("coalesce(nullif(accounts.shared_inbox_url, ''), accounts.inbox_url) AS preferred_inbox_url"))
      DeliveryFailureTracker.without_unavailable(urls)
    end

    def coalesced_activity_timestamps
      Arel.sql(
        <<~SQL.squish
          COALESCE(users.current_sign_in_at, account_stats.last_status_at, to_timestamp(0))
        SQL
      )
    end

    def from_text(text)
      return [] if text.blank?

      text.scan(MENTION_RE).map { |match| match.first.split('@', 2) }.uniq.filter_map do |(username, domain)|
        domain = if TagManager.instance.local_domain?(domain)
                   nil
                 else
                   TagManager.instance.normalize_domain(domain)
                 end

        EntityCache.instance.mention(username, domain)
      end
    end

    def inverse_alias(key, original_key)
      define_method(:"#{key}=") do |value|
        public_send(:"#{original_key}=", !ActiveModel::Type::Boolean.new.cast(value))
      end

      define_method(key) do
        !public_send(original_key)
      end
    end
  end

  inverse_alias :show_collections, :hide_collections
  inverse_alias :unlocked, :locked

  def emojis
    @emojis ||= CustomEmoji.from_text(emojifiable_text, domain)
  end

  before_validation :prepare_contents, if: :local?
  before_create :generate_keys
  before_destroy :clean_feed_manager

  def ensure_keys!
    return unless local? && private_key.blank? && public_key.blank?

    generate_keys
    save!
  end

  def featureable?
    local? && discoverable?
  end

  private

  def prepare_contents
    display_name&.strip!
    note&.strip!
  end

  def generate_keys
    return unless local? && private_key.blank? && public_key.blank?

    keypair = OpenSSL::PKey::RSA.new(2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end

  def normalize_domain
    return if local?

    super
  end

  def emojifiable_text
    [note, display_name, fields.map(&:name), fields.map(&:value)].join(' ')
  end

  def clean_feed_manager
    FeedManager.instance.clean_feeds!(:home, [id])
  end

  def create_canonical_email_block!
    return unless local? && user_email.present?

    begin
      CanonicalEmailBlock.create(reference_account: self, email: user_email)
    rescue ActiveRecord::RecordNotUnique
      # A canonical e-mail block may already exist for the same e-mail
    end
  end

  def destroy_canonical_email_block!
    return unless local?

    CanonicalEmailBlock.where(reference_account: self).delete_all
  end

  # NOTE: the `account.created` webhook is triggered by the `User` model, not `Account`.
  def trigger_update_webhooks
    TriggerWebhookWorker.perform_async('account.updated', 'Account', id) if local?
  end
end
