# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                            :bigint(8)        not null, primary key
#  username                      :string           default(""), not null
#  domain                        :string
#  private_key                   :text
#  public_key                    :text             default(""), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  note                          :text             default(""), not null
#  display_name                  :string           default(""), not null
#  uri                           :string           default(""), not null
#  url                           :string
#  avatar_file_name              :string
#  avatar_content_type           :string
#  avatar_file_size              :integer
#  avatar_updated_at             :datetime
#  header_file_name              :string
#  header_content_type           :string
#  header_file_size              :integer
#  header_updated_at             :datetime
#  avatar_remote_url             :string
#  locked                        :boolean          default(FALSE), not null
#  header_remote_url             :string           default(""), not null
#  last_webfingered_at           :datetime
#  inbox_url                     :string           default(""), not null
#  outbox_url                    :string           default(""), not null
#  shared_inbox_url              :string           default(""), not null
#  followers_url                 :string           default(""), not null
#  protocol                      :integer          default("ostatus"), not null
#  memorial                      :boolean          default(FALSE), not null
#  moved_to_account_id           :bigint(8)
#  featured_collection_url       :string
#  fields                        :jsonb
#  actor_type                    :string
#  discoverable                  :boolean
#  also_known_as                 :string           is an Array
#  silenced_at                   :datetime
#  suspended_at                  :datetime
#  hide_collections              :boolean
#  avatar_storage_schema_version :integer
#  header_storage_schema_version :integer
#  devices_url                   :string
#  suspension_origin             :integer
#  sensitized_at                 :datetime
#  trendable                     :boolean
#  reviewed_at                   :datetime
#  requested_review_at           :datetime
#  indexable                     :boolean          default(FALSE), not null
#

class Account < ApplicationRecord
  self.ignored_columns += %w(
    subscription_expires_at
    secret
    remote_url
    salmon_url
    hub_url
    trust_level
  )

  BACKGROUND_REFRESH_INTERVAL = 1.week.freeze

  USERNAME_RE   = /[a-z0-9_]+([a-z0-9_.-]+[a-z0-9_]+)?/i
  MENTION_RE    = %r{(?<![=/[:word:]])@((#{USERNAME_RE})(?:@[[:word:].-]+[[:word:]]+)?)}i
  URL_PREFIX_RE = %r{\Ahttp(s?)://[^/]+}
  USERNAME_ONLY_RE = /\A#{USERNAME_RE}\z/i

  include Attachmentable # Load prior to Avatar & Header concerns

  include Account::Associations
  include Account::Avatar
  include Account::Counters
  include Account::FinderConcern
  include Account::Header
  include Account::Interactions
  include Account::Merging
  include Account::Search
  include Account::StatusesSearch
  include DomainMaterializable
  include DomainNormalizable
  include Paginable

  MAX_DISPLAY_NAME_LENGTH = (ENV['MAX_DISPLAY_NAME_CHARS'] || 30).to_i
  MAX_NOTE_LENGTH = (ENV['MAX_BIO_CHARS'] || 500).to_i
  DEFAULT_FIELDS_SIZE = (ENV['MAX_PROFILE_FIELDS'] || 4).to_i

  enum protocol: { ostatus: 0, activitypub: 1 }
  enum suspension_origin: { local: 0, remote: 1 }, _prefix: true

  validates :username, presence: true
  validates_with UniqueUsernameValidator, if: -> { will_save_change_to_username? }

  # Remote user validations, also applies to internal actors
  validates :username, format: { with: USERNAME_ONLY_RE }, if: -> { (!local? || actor_type == 'Application') && will_save_change_to_username? }

  # Remote user validations
  validates :uri, presence: true, unless: :local?, on: :create

  # Local user validations
  validates :username, format: { with: /\A[a-z0-9_]+\z/i }, length: { maximum: 30 }, if: -> { local? && will_save_change_to_username? && actor_type != 'Application' }
  validates_with UnreservedUsernameValidator, if: -> { local? && will_save_change_to_username? && actor_type != 'Application' }
  validates :display_name, length: { maximum: MAX_DISPLAY_NAME_LENGTH }, if: -> { local? && will_save_change_to_display_name? }
  validates :note, note_length: { maximum: MAX_NOTE_LENGTH }, if: -> { local? && will_save_change_to_note? }
  validates :fields, length: { maximum: DEFAULT_FIELDS_SIZE }, if: -> { local? && will_save_change_to_fields? }
  validates :uri, absence: true, if: :local?, on: :create
  validates :inbox_url, absence: true, if: :local?, on: :create
  validates :shared_inbox_url, absence: true, if: :local?, on: :create
  validates :followers_url, absence: true, if: :local?, on: :create

  normalizes :username, with: ->(username) { username.squish }

  scope :remote, -> { where.not(domain: nil) }
  scope :local, -> { where(domain: nil) }
  scope :partitioned, -> { order(Arel.sql('row_number() over (partition by domain)')) }
  scope :silenced, -> { where.not(silenced_at: nil) }
  scope :suspended, -> { where.not(suspended_at: nil) }
  scope :sensitized, -> { where.not(sensitized_at: nil) }
  scope :without_suspended, -> { where(suspended_at: nil) }
  scope :without_silenced, -> { where(silenced_at: nil) }
  scope :without_instance_actor, -> { where.not(id: -99) }
  scope :recent, -> { reorder(id: :desc) }
  scope :bots, -> { where(actor_type: %w(Application Service)) }
  scope :groups, -> { where(actor_type: 'Group') }
  scope :alphabetic, -> { order(domain: :asc, username: :asc) }
  scope :matches_uri_prefix, ->(value) { where(arel_table[:uri].matches("#{sanitize_sql_like(value)}/%", false, true)).or(where(uri: value)) }
  scope :matches_username, ->(value) { where('lower((username)::text) LIKE lower(?)', "#{value}%") }
  scope :matches_display_name, ->(value) { where(arel_table[:display_name].matches("#{value}%")) }
  scope :without_unapproved, -> { left_outer_joins(:user).merge(User.approved.confirmed).or(remote) }
  scope :auditable, -> { where(id: Admin::ActionLog.select(:account_id).distinct) }
  scope :searchable, -> { without_unapproved.without_suspended.where(moved_to_account_id: nil) }
  scope :discoverable, -> { searchable.without_silenced.where(discoverable: true).joins(:account_stat) }
  scope :by_recent_status, -> { includes(:account_stat).merge(AccountStat.order('last_status_at DESC NULLS LAST')).references(:account_stat) }
  scope :by_recent_activity, -> { left_joins(:user, :account_stat).order(coalesced_activity_timestamps.desc).order(id: :desc) }
  scope :popular, -> { order('account_stats.followers_count desc') }
  scope :by_domain_and_subdomains, ->(domain) { where(domain: Instance.by_domain_and_subdomains(domain).select(:domain)) }
  scope :not_excluded_by_account, ->(account) { where.not(id: account.excluded_from_timeline_account_ids) }
  scope :not_domain_blocked_by_account, ->(account) { where(arel_table[:domain].eq(nil).or(arel_table[:domain].not_in(account.excluded_from_timeline_domains))) }

  after_update_commit :trigger_update_webhooks

  delegate :email,
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

  def moved?
    moved_to_account_id.present?
  end

  def bot?
    %w(Application Service).include? actor_type
  end

  def instance_actor?
    id == -99
  end

  alias bot bot?

  def bot=(val)
    self.actor_type = ActiveModel::Type::Boolean.new.cast(val) ? 'Service' : 'Person'
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
    last_webfingered_at.nil? || last_webfingered_at <= 1.day.ago
  end

  def schedule_refresh_if_stale!
    return unless last_webfingered_at.present? && last_webfingered_at <= BACKGROUND_REFRESH_INTERVAL.ago

    AccountRefreshWorker.perform_in(rand(6.hours.to_i), id)
  end

  def refresh!
    ResolveAccountService.new.call(acct) unless local?
  end

  def silenced?
    silenced_at.present?
  end

  def silence!(date = Time.now.utc)
    update!(silenced_at: date)
  end

  def unsilence!
    update!(silenced_at: nil)
  end

  def suspended?
    suspended_at.present? && !instance_actor?
  end

  def suspended_permanently?
    suspended? && deletion_request.nil?
  end

  def suspended_temporarily?
    suspended? && deletion_request.present?
  end

  alias unavailable? suspended?
  alias permanently_unavailable? suspended_permanently?

  def suspend!(date: Time.now.utc, origin: :local, block_email: true)
    transaction do
      create_deletion_request!
      update!(suspended_at: date, suspension_origin: origin)
      create_canonical_email_block! if block_email
    end
  end

  def unsuspend!
    transaction do
      deletion_request&.destroy!
      update!(suspended_at: nil, suspension_origin: nil)
      destroy_canonical_email_block!
    end
  end

  def sensitized?
    sensitized_at.present?
  end

  def sensitize!(date = Time.now.utc)
    update!(sensitized_at: date)
  end

  def unsensitize!
    update!(sensitized_at: nil)
  end

  def memorialize!
    update!(memorial: true)
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
        next if attr[:name].blank?

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

  def requires_review?
    reviewed_at.nil?
  end

  def reviewed?
    reviewed_at.present?
  end

  def requested_review?
    requested_review_at.present?
  end

  def requires_review_notification?
    requires_review? && !requested_review?
  end

  class << self
    def readonly_attributes
      super - %w(statuses_count following_count followers_count)
    end

    def inboxes
      urls = reorder(nil).where(protocol: :activitypub).group(:preferred_inbox_url).pluck(Arel.sql("coalesce(nullif(accounts.shared_inbox_url, ''), accounts.inbox_url) AS preferred_inbox_url"))
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
