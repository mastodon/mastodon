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
#  poll_id                      :bigint(8)
#  deleted_at                   :datetime
#  edited_at                    :datetime
#  trendable                    :boolean
#  ordered_media_attachment_ids :bigint(8)        is an Array
#

class Status < ApplicationRecord
  before_destroy :unlink_from_conversations!

  include Discard::Model
  include Paginable
  include Cacheable
  include StatusThreadingConcern
  include StatusSnapshotConcern
  include RateLimitable

  rate_limit by: :account, family: :statuses

  self.discard_column = :deleted_at

  # If `override_timestamps` is set at creation time, Snowflake ID creation
  # will be based on current time instead of `created_at`
  attr_accessor :override_timestamps

  update_index('statuses', :proper)

  enum visibility: { public: 0, unlisted: 1, private: 2, direct: 3, limited: 4 }, _suffix: :visibility

  belongs_to :application, class_name: 'Doorkeeper::Application', optional: true

  belongs_to :account, inverse_of: :statuses
  belongs_to :in_reply_to_account, class_name: 'Account', optional: true
  belongs_to :conversation, optional: true
  belongs_to :preloadable_poll, class_name: 'Poll', foreign_key: 'poll_id', optional: true

  belongs_to :thread, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :replies, optional: true
  belongs_to :reblog, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblogs, optional: true

  has_many :favourites, inverse_of: :status, dependent: :destroy
  has_many :bookmarks, inverse_of: :status, dependent: :destroy
  has_many :reblogs, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblog, dependent: :destroy
  has_many :reblogged_by_accounts, through: :reblogs, class_name: 'Account', source: :account
  has_many :replies, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :thread
  has_many :mentions, dependent: :destroy, inverse_of: :status
  has_many :mentioned_accounts, through: :mentions, source: :account, class_name: 'Account'
  has_many :active_mentions, -> { active }, class_name: 'Mention', inverse_of: :status
  has_many :media_attachments, dependent: :nullify

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :preview_cards

  has_one :notification, as: :activity, dependent: :destroy
  has_one :status_stat, inverse_of: :status
  has_one :poll, inverse_of: :status, dependent: :destroy
  has_one :trend, class_name: 'StatusTrend', inverse_of: :status

  validates :uri, uniqueness: true, presence: true, unless: :local?
  validates :text, presence: true, unless: -> { with_media? || reblog? }
  validates_with StatusLengthValidator
  validates_with DisallowedHashtagsValidator
  validates :reblog, uniqueness: { scope: :account }, if: :reblog?
  validates :visibility, exclusion: { in: %w(direct limited) }, if: :reblog?

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
  scope :excluding_silenced_accounts, -> { left_outer_joins(:account).where(accounts: { silenced_at: nil }) }
  scope :including_silenced_accounts, -> { left_outer_joins(:account).where.not(accounts: { silenced_at: nil }) }
  scope :not_excluded_by_account, ->(account) { where.not(account_id: account.excluded_from_timeline_account_ids) }
  scope :not_domain_blocked_by_account, ->(account) { account.excluded_from_timeline_domains.blank? ? left_outer_joins(:account) : left_outer_joins(:account).where('accounts.domain IS NULL OR accounts.domain NOT IN (?)', account.excluded_from_timeline_domains) }
  scope :tagged_with_all, lambda { |tag_ids|
    Array(tag_ids).map(&:to_i).reduce(self) do |result, id|
      result.joins("INNER JOIN statuses_tags t#{id} ON t#{id}.status_id = statuses.id AND t#{id}.tag_id = #{id}")
    end
  }
  scope :tagged_with_none, lambda { |tag_ids|
    where('NOT EXISTS (SELECT * FROM statuses_tags forbidden WHERE forbidden.status_id = statuses.id AND forbidden.tag_id IN (?))', tag_ids)
  }

  after_create_commit :trigger_create_webhooks
  after_update_commit :trigger_update_webhooks

  cache_associated :application,
                   :media_attachments,
                   :conversation,
                   :status_stat,
                   :tags,
                   :preview_cards,
                   :preloadable_poll,
                   account: [:account_stat, user: :role],
                   active_mentions: { account: :account_stat },
                   reblog: [
                     :application,
                     :tags,
                     :preview_cards,
                     :media_attachments,
                     :conversation,
                     :status_stat,
                     :preloadable_poll,
                     account: [:account_stat, user: :role],
                     active_mentions: { account: :account_stat },
                   ],
                   thread: { account: :account_stat }

  delegate :domain, to: :account, prefix: true

  REAL_TIME_WINDOW = 6.hours

  def searchable_by(preloaded = nil)
    ids = []

    ids << account_id if local?

    if preloaded.nil?
      ids += mentions.joins(:account).merge(Account.local).active.pluck(:account_id)
      ids += favourites.joins(:account).merge(Account.local).pluck(:account_id)
      ids += reblogs.joins(:account).merge(Account.local).pluck(:account_id)
      ids += bookmarks.joins(:account).merge(Account.local).pluck(:account_id)
      ids += poll.votes.joins(:account).merge(Account.local).pluck(:account_id) if poll.present?
    else
      ids += preloaded.mentions[id] || []
      ids += preloaded.favourites[id] || []
      ids += preloaded.reblogs[id] || []
      ids += preloaded.bookmarks[id] || []
      ids += preloaded.votes[id] || []
    end

    ids.uniq
  end

  def searchable_text
    [
      spoiler_text,
      FormattingHelper.extract_status_plain_text(self),
      preloadable_poll ? preloadable_poll.options.join("\n\n") : nil,
      ordered_media_attachments.map(&:description).join("\n\n"),
    ].compact.join("\n\n")
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
    preview_cards.first
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
    preview_cards.any?
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
      media_attachments
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

  after_create_commit  :increment_counter_caches
  after_destroy_commit :decrement_counter_caches

  after_create_commit :store_uri, if: :local?
  after_create_commit :update_statistics, if: :local?

  before_validation :prepare_contents, if: :local?
  before_validation :set_reblog
  before_validation :set_visibility
  before_validation :set_conversation
  before_validation :set_local

  around_create Mastodon::Snowflake::Callbacks

  after_create :set_poll_id

  class << self
    def selectable_visibilities
      visibilities.keys - %w(direct limited)
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

      return if account_ids.empty?

      accounts = Account.where(id: account_ids).includes(:account_stat, :user).index_by(&:id)

      cached_items.each do |item|
        item.account = accounts[item.account_id]
        item.reblog.account = accounts[item.reblog.account_id] if item.reblog?
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

  def status_stat
    super || build_status_stat
  end

  # Hack to use a "INSERT INTO ... SELECT ..." query instead of "INSERT INTO ... VALUES ..." query
  def self._insert_record(values)
    if values.is_a?(Hash) && values['reblog_of_id'].present?
      primary_key = self.primary_key
      primary_key_value = nil

      if primary_key
        primary_key_value = values[primary_key]

        if !primary_key_value && prefetch_primary_key?
          primary_key_value = next_sequence_value
          values[primary_key] = primary_key_value
        end
      end

      # The following line is where we differ from stock ActiveRecord implementation
      im = _compile_reblog_insert(values)

      # Since we are using SELECT instead of VALUES, a non-error `nil` return is possible.
      # For our purposes, it's equivalent to a foreign key constraint violation
      result = connection.insert(im, "#{self} Create", primary_key || false, primary_key_value)
      raise ActiveRecord::InvalidForeignKey, "(reblog_of_id)=(#{values['reblog_of_id']}) is not present in table \"statuses\"" if result.nil?

      result
    else
      super
    end
  end

  def self._compile_reblog_insert(values)
    # This is somewhat equivalent to the following code of ActiveRecord::Persistence:
    # `arel_table.compile_insert(_substitute_values(values))`
    # The main difference is that we use a `SELECT` instead of a `VALUES` clause,
    # which means we have to build the `SELECT` clause ourselves and do a bit more
    # manual work.

    # Instead of using Arel::InsertManager#values, we are going to use Arel::InsertManager#select
    im = Arel::InsertManager.new
    im.into(arel_table)

    binds = []
    reblog_bind = nil
    values.each do |name, value|
      attr = arel_table[name]
      bind = predicate_builder.build_bind_attribute(attr.name, value)

      im.columns << attr
      binds << bind

      reblog_bind = bind if name == 'reblog_of_id'
    end

    im.select(arel_table.where(arel_table[:id].eq(reblog_bind)).where(arel_table[:deleted_at].eq(nil)).project(*binds))

    im
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
