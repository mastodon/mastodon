# frozen_string_literal: true
# == Schema Information
#
# Table name: statuses
#
#  id                     :bigint(8)        not null, primary key
#  uri                    :string
#  text                   :text             default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  in_reply_to_id         :bigint(8)
#  reblog_of_id           :bigint(8)
#  url                    :string
#  sensitive              :boolean          default(FALSE), not null
#  visibility             :integer          default("public"), not null
#  spoiler_text           :text             default(""), not null
#  reply                  :boolean          default(FALSE), not null
#  language               :string
#  conversation_id        :bigint(8)
#  local                  :boolean
#  account_id             :bigint(8)        not null
#  application_id         :bigint(8)
#  in_reply_to_account_id :bigint(8)
#  poll_id                :bigint(8)
#

class Status < ApplicationRecord
  before_destroy :unlink_from_conversations

  include Paginable
  include Streamable
  include Cacheable
  include StatusThreadingConcern

  # If `override_timestamps` is set at creation time, Snowflake ID creation
  # will be based on current time instead of `created_at`
  attr_accessor :override_timestamps

  update_index('statuses#status', :proper) if Chewy.enabled?

  enum visibility: [:public, :unlisted, :private, :direct, :limited], _suffix: :visibility

  belongs_to :application, class_name: 'Doorkeeper::Application', optional: true

  belongs_to :account, inverse_of: :statuses
  belongs_to :in_reply_to_account, foreign_key: 'in_reply_to_account_id', class_name: 'Account', optional: true
  belongs_to :conversation, optional: true
  belongs_to :preloadable_poll, class_name: 'Poll', foreign_key: 'poll_id', optional: true

  belongs_to :thread, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :replies, optional: true
  belongs_to :reblog, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblogs, optional: true

  has_many :favourites, inverse_of: :status, dependent: :destroy
  has_many :reblogs, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblog, dependent: :destroy
  has_many :replies, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :thread
  has_many :mentions, dependent: :destroy, inverse_of: :status
  has_many :active_mentions, -> { active }, class_name: 'Mention', inverse_of: :status
  has_many :media_attachments, dependent: :nullify

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :preview_cards

  has_one :notification, as: :activity, dependent: :destroy
  has_one :stream_entry, as: :activity, inverse_of: :status
  has_one :status_stat, inverse_of: :status
  has_one :poll, inverse_of: :status, dependent: :destroy

  validates :uri, uniqueness: true, presence: true, unless: :local?
  validates :text, presence: true, unless: -> { with_media? || reblog? }
  validates_with StatusLengthValidator
  validates_with DisallowedHashtagsValidator
  validates :reblog, uniqueness: { scope: :account }, if: :reblog?
  validates :visibility, exclusion: { in: %w(direct limited) }, if: :reblog?

  accepts_nested_attributes_for :poll

  default_scope { recent }

  scope :recent, -> { reorder(id: :desc) }
  scope :remote, -> { where(local: false).or(where.not(uri: nil)) }
  scope :local,  -> { where(local: true).or(where(uri: nil)) }

  scope :without_replies, -> { where('statuses.reply = FALSE OR statuses.in_reply_to_account_id = statuses.account_id') }
  scope :without_reblogs, -> { where('statuses.reblog_of_id IS NULL') }
  scope :with_public_visibility, -> { where(visibility: :public) }
  scope :tagged_with, ->(tag) { joins(:statuses_tags).where(statuses_tags: { tag_id: tag }) }
  scope :excluding_silenced_accounts, -> { left_outer_joins(:account).where(accounts: { silenced: false }) }
  scope :including_silenced_accounts, -> { left_outer_joins(:account).where(accounts: { silenced: true }) }
  scope :not_excluded_by_account, ->(account) { where.not(account_id: account.excluded_from_timeline_account_ids) }
  scope :not_domain_blocked_by_account, ->(account) { account.excluded_from_timeline_domains.blank? ? left_outer_joins(:account) : left_outer_joins(:account).where('accounts.domain IS NULL OR accounts.domain NOT IN (?)', account.excluded_from_timeline_domains) }
  scope :tagged_with_all, ->(tags) {
    Array(tags).map(&:id).map(&:to_i).reduce(self) do |result, id|
      result.joins("INNER JOIN statuses_tags t#{id} ON t#{id}.status_id = statuses.id AND t#{id}.tag_id = #{id}")
    end
  }
  scope :tagged_with_none, ->(tags) {
    Array(tags).map(&:id).map(&:to_i).reduce(self) do |result, id|
      result.joins("LEFT OUTER JOIN statuses_tags t#{id} ON t#{id}.status_id = statuses.id AND t#{id}.tag_id = #{id}")
            .where("t#{id}.tag_id IS NULL")
    end
  }

  cache_associated :application,
                   :media_attachments,
                   :conversation,
                   :status_stat,
                   :tags,
                   :preview_cards,
                   :stream_entry,
                   :preloadable_poll,
                   account: :account_stat,
                   active_mentions: { account: :account_stat },
                   reblog: [
                     :application,
                     :stream_entry,
                     :tags,
                     :preview_cards,
                     :media_attachments,
                     :conversation,
                     :status_stat,
                     :preloadable_poll,
                     account: :account_stat,
                     active_mentions: { account: :account_stat },
                   ],
                   thread: { account: :account_stat }

  delegate :domain, to: :account, prefix: true

  REAL_TIME_WINDOW = 6.hours

  def searchable_by(preloaded = nil)
    ids = [account_id]

    if preloaded.nil?
      ids += mentions.pluck(:account_id)
      ids += favourites.pluck(:account_id)
      ids += reblogs.pluck(:account_id)
    else
      ids += preloaded.mentions[id] || []
      ids += preloaded.favourites[id] || []
      ids += preloaded.reblogs[id] || []
    end

    ids.uniq
  end

  def reply?
    !in_reply_to_id.nil? || attributes['reply']
  end

  def local?
    attributes['local'] || uri.nil?
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

  def title
    if destroyed?
      "#{account.acct} deleted status"
    else
      reblog? ? "#{account.acct} shared a status by #{reblog.account.acct}" : "New status by #{account.acct}"
    end
  end

  def hidden?
    private_visibility? || direct_visibility? || limited_visibility?
  end

  def distributable?
    public_visibility? || unlisted_visibility?
  end

  def with_media?
    media_attachments.any?
  end

  def non_sensitive_with_media?
    !sensitive? && with_media?
  end

  def emojis
    return @emojis if defined?(@emojis)

    fields  = [spoiler_text, text]
    fields += preloadable_poll.options unless preloadable_poll.nil?

    @emojis = CustomEmoji.from_text(fields.join(' '), account.domain)
  end

  def mark_for_mass_destruction!
    @marked_for_mass_destruction = true
  end

  def marked_for_mass_destruction?
    @marked_for_mass_destruction
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

  after_create_commit  :increment_counter_caches
  after_destroy_commit :decrement_counter_caches

  after_create_commit :store_uri, if: :local?
  after_create_commit :update_statistics, if: :local?

  around_create Mastodon::Snowflake::Callbacks

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

    def as_home_timeline(account)
      where(account: [account] + account.following).where(visibility: [:public, :unlisted, :private])
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

    def as_public_timeline(account = nil, local_only = false)
      query = timeline_scope(local_only).without_replies

      apply_timeline_filters(query, account, local_only)
    end

    def as_tag_timeline(tag, account = nil, local_only = false)
      query = timeline_scope(local_only).tagged_with(tag)

      apply_timeline_filters(query, account, local_only)
    end

    def as_outbox_timeline(account)
      where(account: account, visibility: :public)
    end

    def favourites_map(status_ids, account_id)
      Favourite.select('status_id').where(status_id: status_ids).where(account_id: account_id).each_with_object({}) { |f, h| h[f.status_id] = true }
    end

    def reblogs_map(status_ids, account_id)
      select('reblog_of_id').where(reblog_of_id: status_ids).where(account_id: account_id).reorder(nil).each_with_object({}) { |s, h| h[s.reblog_of_id] = true }
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

      accounts = Account.where(id: account_ids).includes(:account_stat).each_with_object({}) { |a, h| h[a.id] = a }

      cached_items.each do |item|
        item.account = accounts[item.account_id]
        item.reblog.account = accounts[item.reblog.account_id] if item.reblog?
      end
    end

    def permitted_for(target_account, account)
      visibility = [:public, :unlisted]

      if account.nil?
        where(visibility: visibility)
      elsif target_account.blocking?(account) # get rid of blocked peeps
        none
      elsif account.id == target_account.id # author can see own stuff
        all
      else
        # followers can see followers-only stuff, but also things they are mentioned in.
        # non-followers can see everything that isn't private/direct, but can see stuff they are mentioned in.
        visibility.push(:private) if account.following?(target_account)

        scope = left_outer_joins(:reblog)

        scope.where(visibility: visibility)
             .or(scope.where(id: account.mentions.select(:status_id)))
             .merge(scope.where(reblog_of_id: nil).or(scope.where.not(reblogs_statuses: { account_id: account.excluded_from_timeline_account_ids })))
      end
    end

    private

    def timeline_scope(local_only = false)
      starting_scope = local_only ? Status.local : Status
      starting_scope
        .with_public_visibility
        .without_reblogs
    end

    def apply_timeline_filters(query, account, local_only)
      if account.nil?
        filter_timeline_default(query)
      else
        filter_timeline_for_account(query, account, local_only)
      end
    end

    def filter_timeline_for_account(query, account, local_only)
      query = query.not_excluded_by_account(account)
      query = query.not_domain_blocked_by_account(account) unless local_only
      query = query.in_chosen_languages(account) if account.chosen_languages.present?
      query.merge(account_silencing_filter(account))
    end

    def filter_timeline_default(query)
      query.excluding_silenced_accounts
    end

    def account_silencing_filter(account)
      if account.silenced?
        including_myself = left_outer_joins(:account).where(account_id: account.id).references(:accounts)
        excluding_silenced_accounts.or(including_myself)
      else
        excluding_silenced_accounts
      end
    end
  end

  private

  def update_status_stat!(attrs)
    return if marked_for_destruction? || destroyed?

    record = status_stat || build_status_stat
    record.update(attrs)
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
    return unless public_visibility? || unlisted_visibility?
    ActivityTracker.increment('activity:statuses:local')
  end

  def increment_counter_caches
    return if direct_visibility?

    account&.increment_count!(:statuses_count)
    reblog&.increment_count!(:reblogs_count) if reblog? && (public_visibility? || unlisted_visibility?)
    thread&.increment_count!(:replies_count) if in_reply_to_id.present? && (public_visibility? || unlisted_visibility?)
  end

  def decrement_counter_caches
    return if direct_visibility? || marked_for_mass_destruction?

    account&.decrement_count!(:statuses_count)
    reblog&.decrement_count!(:reblogs_count) if reblog? && (public_visibility? || unlisted_visibility?)
    thread&.decrement_count!(:replies_count) if in_reply_to_id.present? && (public_visibility? || unlisted_visibility?)
  end

  def unlink_from_conversations
    return unless direct_visibility?

    mentioned_accounts = mentions.includes(:account).map(&:account)
    inbox_owners       = mentioned_accounts.select(&:local?) + (account.local? ? [account] : [])

    inbox_owners.each do |inbox_owner|
      AccountConversation.remove_status(inbox_owner, self)
    end
  end
end
