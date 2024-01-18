# frozen_string_literal: true

# == Schema Information
#
# Table name: statuses
#
#  id                           :bigint(8)        not null, primary key
#  uri                          :string
#  text                         :text             default(""), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  in_reply_to_id               :bigint(8)
#  reblog_of_id                 :bigint(8)
#  url                          :string
#  sensitive                    :boolean          default(FALSE), not null
#  visibility                   :integer          default("public"), not null
#  spoiler_text                 :text             default(""), not null
#  reply                        :boolean          default(FALSE), not null
#  language                     :string
#  conversation_id              :bigint(8)
#  local                        :boolean
#  account_id                   :bigint(8)        not null
#  application_id               :bigint(8)
#  in_reply_to_account_id       :bigint(8)
#  local_only                   :boolean
#  poll_id                      :bigint(8)
#  content_type                 :string
#  deleted_at                   :datetime
#  edited_at                    :datetime
#  trendable                    :boolean
#  ordered_media_attachment_ids :bigint(8)        is an Array
#

class Status < ApplicationRecord
  include Cacheable
  include Discard::Model
  include Paginable
  include RateLimitable
  include Status::SafeReblogInsert
  include Status::SearchConcern
  include Status::SnapshotConcern
  include Status::ThreadingConcern

  rate_limit by: :account, family: :statuses

  self.discard_column = :deleted_at

  # If `override_timestamps` is set at creation time, Snowflake ID creation
  # will be based on current time instead of `created_at`
  attr_accessor :override_timestamps

  update_index('statuses', :proper)
  update_index('public_statuses', :proper)

  enum visibility: { public: 0, unlisted: 1, private: 2, direct: 3, limited: 4 }, _suffix: :visibility

  belongs_to :application, class_name: 'Doorkeeper::Application', optional: true

  belongs_to :account, inverse_of: :statuses
  belongs_to :in_reply_to_account, class_name: 'Account', optional: true
  belongs_to :conversation, optional: true
  belongs_to :preloadable_poll, class_name: 'Poll', foreign_key: 'poll_id', optional: true, inverse_of: false

  with_options class_name: 'Status', optional: true do
    belongs_to :thread, foreign_key: 'in_reply_to_id', inverse_of: :replies
    belongs_to :reblog, foreign_key: 'reblog_of_id', inverse_of: :reblogs
  end

  has_many :favourites, inverse_of: :status, dependent: :destroy
  has_many :bookmarks, inverse_of: :status, dependent: :destroy
  has_many :reblogs, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblog, dependent: :destroy
  has_many :reblogged_by_accounts, through: :reblogs, class_name: 'Account', source: :account
  has_many :replies, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :thread, dependent: nil
  has_many :mentions, dependent: :destroy, inverse_of: :status
  has_many :mentioned_accounts, through: :mentions, source: :account, class_name: 'Account'
  has_many :media_attachments, dependent: :nullify

  # The `dependent` option is enabled by the initial `mentions` association declaration
  has_many :active_mentions, -> { active }, class_name: 'Mention', inverse_of: :status # rubocop:disable Rails/HasManyOrHasOneDependent

  # Those associations are used for the private search index
  has_many :local_mentioned, -> { merge(Account.local) }, through: :active_mentions, source: :account
  has_many :local_favorited, -> { merge(Account.local) }, through: :favourites, source: :account
  has_many :local_reblogged, -> { merge(Account.local) }, through: :reblogs, source: :account
  has_many :local_bookmarked, -> { merge(Account.local) }, through: :bookmarks, source: :account

  has_and_belongs_to_many :tags

  has_one :preview_cards_status, inverse_of: :status, dependent: :delete

  has_one :notification, as: :activity, dependent: :destroy
  has_one :status_stat, inverse_of: :status, dependent: nil
  has_one :poll, inverse_of: :status, dependent: :destroy
  has_one :trend, class_name: 'StatusTrend', inverse_of: :status, dependent: nil

  validates :uri, uniqueness: true, presence: true, unless: :local?
  validates :text, presence: true, unless: -> { with_media? || reblog? }
  validates_with StatusLengthValidator
  validates_with DisallowedHashtagsValidator
  validates :reblog, uniqueness: { scope: :account }, if: :reblog?
  validates :visibility, exclusion: { in: %w(direct limited) }, if: :reblog?
  validates :content_type, inclusion: { in: %w(text/plain text/markdown text/html) }, allow_nil: true

  accepts_nested_attributes_for :poll

  default_scope { recent.kept }

  scope :recent, -> { reorder(id: :desc) }
  scope :remote, -> { where(local: false).where.not(uri: nil) }
  scope :local,  -> { where(local: true).or(where(uri: nil)) }
  scope :with_accounts, ->(ids) { where(id: ids).includes(:account) }
  scope :without_replies, -> { where('statuses.reply = FALSE OR statuses.in_reply_to_account_id = statuses.account_id') }
  scope :without_reblogs, -> { where(statuses: { reblog_of_id: nil }) }
  scope :with_public_visibility, -> { where(visibility: :public) }
  scope :tagged_with, ->(tag_ids) { joins(:statuses_tags).where(statuses_tags: { tag_id: tag_ids }) }
  scope :not_excluded_by_account, ->(account) { where.not(account_id: account.excluded_from_timeline_account_ids) }
  scope :not_domain_blocked_by_account, ->(account) { account.excluded_from_timeline_domains.blank? ? left_outer_joins(:account) : left_outer_joins(:account).where('accounts.domain IS NULL OR accounts.domain NOT IN (?)', account.excluded_from_timeline_domains) }
  scope :tagged_with_all, lambda { |tag_ids|
    Array(tag_ids).map(&:to_i).reduce(self) do |result, id|
      result.where(<<~SQL.squish, tag_id: id)
        EXISTS(SELECT 1 FROM statuses_tags WHERE statuses_tags.status_id = statuses.id AND statuses_tags.tag_id = :tag_id)
      SQL
    end
  }
  scope :tagged_with_none, lambda { |tag_ids|
    where('NOT EXISTS (SELECT * FROM statuses_tags forbidden WHERE forbidden.status_id = statuses.id AND forbidden.tag_id IN (?))', tag_ids)
  }

  scope :not_local_only, -> { where(local_only: [false, nil]) }

  after_create_commit :trigger_create_webhooks
  after_update_commit :trigger_update_webhooks

  after_create_commit  :increment_counter_caches
  after_destroy_commit :decrement_counter_caches

  after_create_commit :store_uri, if: :local?
  after_create_commit :update_statistics, if: :local?

  before_validation :prepare_contents, if: :local?
  before_validation :set_reblog
  before_validation :set_visibility
  before_validation :set_conversation
  before_validation :set_local

  before_create :set_local_only

  around_create Mastodon::Snowflake::Callbacks

  after_create :set_poll_id

  # The `prepend: true` option below ensures this runs before
  # the `dependent: destroy` callbacks remove relevant records
  before_destroy :unlink_from_conversations!, prepend: true

  cache_associated :application,
                   :media_attachments,
                   :conversation,
                   :status_stat,
                   :tags,
                   :preloadable_poll,
                   preview_cards_status: [:preview_card],
                   account: [:account_stat, user: :role],
                   active_mentions: { account: :account_stat },
                   reblog: [
                     :application,
                     :tags,
                     :media_attachments,
                     :conversation,
                     :status_stat,
                     :preloadable_poll,
                     preview_cards_status: [:preview_card],
                     account: [:account_stat, user: :role],
                     active_mentions: { account: :account_stat },
                   ],
                   thread: { account: :account_stat }

  delegate :domain, to: :account, prefix: true

  REAL_TIME_WINDOW = 6.hours

  def cache_key
    "v3:#{super}"
  end

  def to_log_human_identifier
    account.acct
  end

  def to_log_permalink
    ActivityPub::TagManager.instance.uri_for(self)
  end

  def reply?
    !in_reply_to_id.nil? || attributes['reply']
  end

  def local?
    attributes['local'] || uri.nil?
  end

  def in_reply_to_local_account?
    reply? && thread&.account&.local?
  end

  def reblog?
    !reblog_of_id.nil?
  end

  def within_realtime_window?
    created_at >= REAL_TIME_WINDOW.ago
  end

  def verb
    if destroyed?
      :delete
    else
      reblog? ? :share : :post
    end
  end

  def object_type
    reply? ? :comment : :note
  end

  def proper
    reblog? ? reblog : self
  end

  def content
    proper.text
  end

  def target
    reblog
  end

  def preview_card
    preview_cards_status&.preview_card&.tap { |x| x.original_url = preview_cards_status.url }
  end

  def reset_preview_card!
    PreviewCardsStatus.where(status_id: id).delete_all
  end

  def hidden?
    !distributable?
  end

  def distributable?
    public_visibility? || unlisted_visibility?
  end

  alias sign? distributable?

  def with_media?
    ordered_media_attachments.any?
  end

  def with_preview_card?
    preview_cards_status.present?
  end

  def with_poll?
    preloadable_poll.present?
  end

  def non_sensitive_with_media?
    !sensitive? && with_media?
  end

  def reported?
    @reported ||= Report.where(target_account: account).unresolved.where('? = ANY(status_ids)', id).exists?
  end

  def emojis
    return @emojis if defined?(@emojis)

    fields  = [spoiler_text, text]
    fields += preloadable_poll.options unless preloadable_poll.nil?

    @emojis = CustomEmoji.from_text(fields.join(' '), account.domain)
  end

  def ordered_media_attachments
    if ordered_media_attachment_ids.nil?
      # NOTE: sort Ruby-side to avoid hitting the database when the status is
      # not persisted to database yet
      media_attachments.sort_by(&:id)
    else
      map = media_attachments.index_by(&:id)
      ordered_media_attachment_ids.filter_map { |media_attachment_id| map[media_attachment_id] }
    end
  end

  def replies_count
    status_stat&.replies_count || 0
  end

  def reblogs_count
    status_stat&.reblogs_count || 0
  end

  def favourites_count
    status_stat&.favourites_count || 0
  end

  def increment_count!(key)
    update_status_stat!(key => public_send(key) + 1)
  end

  def decrement_count!(key)
    update_status_stat!(key => [public_send(key) - 1, 0].max)
  end

  def trendable?
    if attributes['trendable'].nil?
      account.trendable?
    else
      attributes['trendable']
    end
  end

  def requires_review?
    attributes['trendable'].nil? && account.requires_review?
  end

  def requires_review_notification?
    attributes['trendable'].nil? && account.requires_review_notification?
  end

  class << self
    def selectable_visibilities
      visibilities.keys - %w(direct limited)
    end

    def as_direct_timeline(account, limit = 20, max_id = nil, since_id = nil)
      # direct timeline is mix of direct message from_me and to_me.
      # 2 queries are executed with pagination.
      # constant expression using arel_table is required for partial index

      # _from_me part does not require any timeline filters
      query_from_me = where(account_id: account.id)
                      .where(Status.arel_table[:visibility].eq(3))
                      .limit(limit)
                      .order('statuses.id DESC')

      # _to_me part requires mute and block filter.
      # FIXME: may we check mutes.hide_notifications?
      query_to_me = Status
                    .joins(:mentions)
                    .merge(Mention.where(account_id: account.id))
                    .where(Status.arel_table[:visibility].eq(3))
                    .limit(limit)
                    .order('mentions.status_id DESC')
                    .not_excluded_by_account(account)

      if max_id.present?
        query_from_me = query_from_me.where('statuses.id < ?', max_id)
        query_to_me = query_to_me.where('mentions.status_id < ?', max_id)
      end

      if since_id.present?
        query_from_me = query_from_me.where('statuses.id > ?', since_id)
        query_to_me = query_to_me.where('mentions.status_id > ?', since_id)
      end

      # returns ActiveRecord.Relation
      items = (query_from_me.select(:id).to_a + query_to_me.select(:id).to_a).uniq(&:id).sort_by(&:id).reverse.take(limit)
      Status.where(id: items.map(&:id))
    end

    def favourites_map(status_ids, account_id)
      Favourite.select('status_id').where(status_id: status_ids).where(account_id: account_id).each_with_object({}) { |f, h| h[f.status_id] = true }
    end

    def bookmarks_map(status_ids, account_id)
      Bookmark.select('status_id').where(status_id: status_ids).where(account_id: account_id).map { |f| [f.status_id, true] }.to_h
    end

    def reblogs_map(status_ids, account_id)
      unscoped.select('reblog_of_id').where(reblog_of_id: status_ids).where(account_id: account_id).each_with_object({}) { |s, h| h[s.reblog_of_id] = true }
    end

    def mutes_map(conversation_ids, account_id)
      ConversationMute.select('conversation_id').where(conversation_id: conversation_ids).where(account_id: account_id).each_with_object({}) { |m, h| h[m.conversation_id] = true }
    end

    def pins_map(status_ids, account_id)
      StatusPin.select('status_id').where(status_id: status_ids).where(account_id: account_id).each_with_object({}) { |p, h| h[p.status_id] = true }
    end

    def reload_stale_associations!(cached_items)
      account_ids = []

      cached_items.each do |item|
        account_ids << item.account_id
        account_ids << item.reblog.account_id if item.reblog?
      end

      account_ids.uniq!

      status_ids = cached_items.map { |item| item.reblog? ? item.reblog_of_id : item.id }.uniq

      return if account_ids.empty?

      accounts = Account.where(id: account_ids).includes(:account_stat, :user).index_by(&:id)

      status_stats = StatusStat.where(status_id: status_ids).index_by(&:status_id)

      cached_items.each do |item|
        item.account = accounts[item.account_id]
        item.reblog.account = accounts[item.reblog.account_id] if item.reblog?

        if item.reblog?
          status_stat = status_stats[item.reblog.id]
          item.reblog.status_stat = status_stat if status_stat.present?
        else
          status_stat = status_stats[item.id]
          item.status_stat = status_stat if status_stat.present?
        end
      end
    end

    def from_text(text)
      return [] if text.blank?

      text.scan(FetchLinkCardService::URL_PATTERN).map(&:second).uniq.filter_map do |url|
        status = if TagManager.instance.local_url?(url)
                   ActivityPub::TagManager.instance.uri_to_resource(url, Status)
                 else
                   EntityCache.instance.status(url)
                 end

        status&.distributable? ? status : nil
      end
    end
  end

  def marked_local_only?
    # match both with and without U+FE0F (the emoji variation selector)
    /#{local_only_emoji}\ufe0f?\z/.match?(content)
  end

  def local_only_emoji
    '👁'
  end

  def status_stat
    super || build_status_stat
  end

  def discard_with_reblogs
    discard_time = Time.current
    Status.unscoped.where(reblog_of_id: id, deleted_at: [nil, deleted_at]).in_batches.update_all(deleted_at: discard_time) unless reblog?
    update_attribute(:deleted_at, discard_time)
  end

  def unlink_from_conversations!
    return unless direct_visibility?

    inbox_owners = mentioned_accounts.local
    inbox_owners += [account] if account.local?

    inbox_owners.each do |inbox_owner|
      AccountConversation.remove_status(inbox_owner, self)
    end
  end

  private

  def update_status_stat!(attrs)
    return if marked_for_destruction? || destroyed?

    status_stat.update(attrs)
  end

  def store_uri
    update_column(:uri, ActivityPub::TagManager.instance.uri_for(self)) if uri.nil?
  end

  def prepare_contents
    text&.strip!
    spoiler_text&.strip!
  end

  def set_reblog
    self.reblog = reblog.reblog if reblog? && reblog.reblog?
  end

  def set_poll_id
    update_column(:poll_id, poll.id) if association(:poll).loaded? && poll.present?
  end

  def set_visibility
    self.visibility = reblog.visibility if reblog? && visibility.nil?
    self.visibility = (account.locked? ? :private : :public) if visibility.nil?
    self.sensitive  = false if sensitive.nil?
  end

  def set_local_only
    return unless account.domain.nil? && !attribute_changed?(:local_only)

    self.local_only = marked_local_only?
  end

  def set_conversation
    self.thread = thread.reblog if thread&.reblog?

    self.reply = !(in_reply_to_id.nil? && thread.nil?) unless reply

    if reply? && !thread.nil?
      self.in_reply_to_account_id = carried_over_reply_to_account_id
      self.conversation_id        = thread.conversation_id if conversation_id.nil?
    elsif conversation_id.nil?
      self.conversation = Conversation.new
    end
  end

  def carried_over_reply_to_account_id
    if thread.account_id == account_id && thread.reply?
      thread.in_reply_to_account_id
    else
      thread.account_id
    end
  end

  def set_local
    self.local = account.local?
  end

  def update_statistics
    return unless distributable?

    ActivityTracker.increment('activity:statuses:local')
  end

  def increment_counter_caches
    return if direct_visibility?

    account&.increment_count!(:statuses_count)
    reblog&.increment_count!(:reblogs_count) if reblog?
    thread&.increment_count!(:replies_count) if in_reply_to_id.present? && distributable?
  end

  def decrement_counter_caches
    return if direct_visibility? || new_record?

    account&.decrement_count!(:statuses_count)
    reblog&.decrement_count!(:reblogs_count) if reblog?
    thread&.decrement_count!(:replies_count) if in_reply_to_id.present? && distributable?
  end

  def trigger_create_webhooks
    TriggerWebhookWorker.perform_async('status.created', 'Status', id) if local?
  end

  def trigger_update_webhooks
    TriggerWebhookWorker.perform_async('status.updated', 'Status', id) if local?
  end
end
