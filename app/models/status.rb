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
  before_destroy :unlink_from_conversations

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

  enum visibility: [:public, :unlisted, :private, :direct, :limited], _suffix: :visibility

  belongs_to :application, class_name: 'Doorkeeper::Application', optional: true

  belongs_to :account, inverse_of: :statuses
  belongs_to :in_reply_to_account, foreign_key: 'in_reply_to_account_id', class_name: 'Account', optional: true
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
  has_many :active_mentions, -> { active }, class_name: 'Mention', inverse_of: :status
  has_many :media_attachments, dependent: :nullify

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :preview_cards

  has_one :notification, as: :activity, dependent: :destroy
  has_one :status_stat, inverse_of: :status
  has_one :poll, inverse_of: :status, dependent: :destroy

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
  scope :without_reblogs, -> { where('statuses.reblog_of_id IS NULL') }
  scope :with_public_visibility, -> { where(visibility: :public) }
  scope :tagged_with, ->(tag_ids) { joins(:statuses_tags).where(statuses_tags: { tag_id: tag_ids }) }
  scope :in_chosen_languages, ->(account) { where(language: nil).or where(language: account.chosen_languages) }
  scope :excluding_silenced_accounts, -> { left_outer_joins(:account).where(accounts: { silenced_at: nil }) }
  scope :including_silenced_accounts, -> { left_outer_joins(:account).where.not(accounts: { silenced_at: nil }) }
  scope :not_excluded_by_account, ->(account) { where.not(account_id: account.excluded_from_timeline_account_ids) }
  scope :not_domain_blocked_by_account, ->(account) { account.excluded_from_timeline_domains.blank? ? left_outer_joins(:account) : left_outer_joins(:account).where('accounts.domain IS NULL OR accounts.domain NOT IN (?)', account.excluded_from_timeline_domains) }
  scope :tagged_with_all, ->(tag_ids) {
    Array(tag_ids).map(&:to_i).reduce(self) do |result, id|
      result.joins("INNER JOIN statuses_tags t#{id} ON t#{id}.status_id = statuses.id AND t#{id}.tag_id = #{id}")
    end
  }
  scope :tagged_with_none, ->(tag_ids) {
    where('NOT EXISTS (SELECT * FROM statuses_tags forbidden WHERE forbidden.status_id = statuses.id AND forbidden.tag_id IN (?))', tag_ids)
  }

  scope :not_local_only, -> { where(local_only: [false, nil]) }

  cache_associated :application,
                   :media_attachments,
                   :conversation,
                   :status_stat,
                   :tags,
                   :preview_cards,
                   :preloadable_poll,
                   account: [:account_stat, :user],
                   active_mentions: { account: :account_stat },
                   reblog: [
                     :application,
                     :tags,
                     :preview_cards,
                     :media_attachments,
                     :conversation,
                     :status_stat,
                     :preloadable_poll,
                     account: [:account_stat, :user],
                     active_mentions: { account: :account_stat },
                   ],
                   thread: { account: :account_stat }

  delegate :domain, to: :account, prefix: true

  REAL_TIME_WINDOW = 6.hours

  def searchable_by(preloaded = nil)
    ids = []

    ids << account_id if local?

    if preloaded.nil?
      ids += mentions.where(account: Account.local, silent: false).pluck(:account_id)
      ids += favourites.where(account: Account.local).pluck(:account_id)
      ids += reblogs.where(account: Account.local).pluck(:account_id)
      ids += bookmarks.where(account: Account.local).pluck(:account_id)
      ids += poll.votes.where(account: Account.local).pluck(:account_id) if poll.present?
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

  around_create Mastodon::Snowflake::Callbacks

  before_create :set_locality

  before_validation :prepare_contents, if: :local?
  before_validation :set_reblog
  before_validation :set_visibility
  before_validation :set_conversation
  before_validation :set_local

  after_create :set_poll_id

  class << self
    def selectable_visibilities
      visibilities.keys - %w(direct limited)
    end

    def in_chosen_languages(account)
      where(language: nil).or where(language: account.chosen_languages)
    end

    def as_direct_timeline(account, limit = 20, max_id = nil, since_id = nil, cache_ids = false)
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

      if cache_ids
        # returns array of cache_ids object that have id and updated_at
        (query_from_me.cache_ids.to_a + query_to_me.cache_ids.to_a).uniq(&:id).sort_by(&:id).reverse.take(limit)
      else
        # returns ActiveRecord.Relation
        items = (query_from_me.select(:id).to_a + query_to_me.select(:id).to_a).uniq(&:id).sort_by(&:id).reverse.take(limit)
        Status.where(id: items.map(&:id))
      end
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
        status = begin
          if TagManager.instance.local_url?(url)
            ActivityPub::TagManager.instance.uri_to_resource(url, Status)
          else
            EntityCache.instance.status(url)
          end
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
    update_column(:poll_id, poll.id) unless poll.nil?
  end

  def set_visibility
    self.visibility = reblog.visibility if reblog? && visibility.nil?
    self.visibility = (account.locked? ? :private : :public) if visibility.nil?
    self.sensitive  = false if sensitive.nil?
  end

  def set_locality
    if account.domain.nil? && !attribute_changed?(:local_only)
      self.local_only = marked_local_only?
    end
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

  def unlink_from_conversations
    return unless direct_visibility?

    mentioned_accounts = (association(:mentions).loaded? ? mentions : mentions.includes(:account)).map(&:account)
    inbox_owners       = mentioned_accounts.select(&:local?) + (account.local? ? [account] : [])

    inbox_owners.each do |inbox_owner|
      AccountConversation.remove_status(inbox_owner, self)
    end
  end
end
