# frozen_string_literal: true

class Status < ApplicationRecord
  include Paginable
  include Streamable
  include Cacheable

  enum visibility: [:public, :unlisted, :private], _suffix: :visibility

  belongs_to :account, inverse_of: :statuses

  belongs_to :thread, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :replies
  belongs_to :reblog, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblogs, touch: true

  has_many :favourites, inverse_of: :status, dependent: :destroy
  has_many :reblogs, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblog, dependent: :destroy
  has_many :replies, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :thread
  has_many :mentions, dependent: :destroy
  has_many :media_attachments, dependent: :destroy
  has_and_belongs_to_many :tags

  has_one :notification, as: :activity, dependent: :destroy

  validates :account, presence: true
  validates :uri, uniqueness: true, unless: 'local?'
  validates :text, presence: true, length: { maximum: 500 }, if: proc { |s| s.local? && !s.reblog? }
  validates :text, presence: true, if: proc { |s| !s.local? && !s.reblog? }
  validates :reblog, uniqueness: { scope: :account, message: 'of status already exists' }, if: 'reblog?'

  default_scope { order('id desc') }

  scope :remote, -> { where.not(uri: nil) }
  scope :local, -> { where(uri: nil) }
  scope :permitted_for, ->(target_account, account) { account&.id == target_account.id || account&.following?(target_account) ? where('1=1') : where.not(visibility: :private) }

  cache_associated :account, :media_attachments, :tags, :stream_entry, mentions: :account, reblog: [:account, :stream_entry, :tags, :media_attachments, mentions: :account], thread: :account

  def local?
    uri.nil?
  end

  def reblog?
    !reblog_of_id.nil?
  end

  def reply?
    !in_reply_to_id.nil?
  end

  def verb
    reblog? ? :share : :post
  end

  def object_type
    reply? ? :comment : :note
  end

  def content
    reblog? ? reblog.text : text
  end

  def target
    reblog
  end

  def title
    content
  end

  def hidden?
    private_visibility?
  end

  def permitted?(other_account = nil)
    private_visibility? ? (account.id == other_account&.id || other_account&.following?(account)) : true
  end

  def ancestors(account = nil)
    ids      = (Status.find_by_sql(['WITH RECURSIVE search_tree(id, in_reply_to_id, path) AS (SELECT id, in_reply_to_id, ARRAY[id] FROM statuses WHERE id = ? UNION ALL SELECT statuses.id, statuses.in_reply_to_id, path || statuses.id FROM search_tree JOIN statuses ON statuses.id = search_tree.in_reply_to_id WHERE NOT statuses.id = ANY(path)) SELECT id FROM search_tree ORDER BY path DESC', id]) - [self]).pluck(:id)
    statuses = Status.where(id: ids).with_includes.group_by(&:id)
    results  = ids.map { |id| statuses[id].first }
    results  = results.reject { |status| filter_from_context?(status, account) }

    results
  end

  def descendants(account = nil)
    ids      = (Status.find_by_sql(['WITH RECURSIVE search_tree(id, path) AS (SELECT id, ARRAY[id] FROM statuses WHERE id = ? UNION ALL SELECT statuses.id, path || statuses.id FROM search_tree JOIN statuses ON statuses.in_reply_to_id = search_tree.id WHERE NOT statuses.id = ANY(path)) SELECT id FROM search_tree ORDER BY path', id]) - [self]).pluck(:id)
    statuses = Status.where(id: ids).with_includes.group_by(&:id)
    results  = ids.map { |id| statuses[id].first }
    results  = results.reject { |status| filter_from_context?(status, account) }

    results
  end

  class << self
    def as_home_timeline(account)
      where(account: [account] + account.following)
    end

    def as_mentions_timeline(account)
      where(id: Mention.where(account: account).select(:status_id))
    end

    def as_public_timeline(account = nil)
      query = joins('LEFT OUTER JOIN accounts ON statuses.account_id = accounts.id')
              .where(visibility: :public)
              .where('(statuses.in_reply_to_id IS NULL OR statuses.in_reply_to_account_id = statuses.account_id)')
              .where('statuses.reblog_of_id IS NULL')

      account.nil? ? filter_timeline_default(query) : filter_timeline_default(filter_timeline(query, account))
    end

    def as_tag_timeline(tag, account = nil)
      query = tag.statuses
                 .joins('LEFT OUTER JOIN accounts ON statuses.account_id = accounts.id')
                 .where(visibility: :public)
                 .where('(statuses.in_reply_to_id IS NULL OR statuses.in_reply_to_account_id = statuses.account_id)')
                 .where('statuses.reblog_of_id IS NULL')

      account.nil? ? filter_timeline_default(query) : filter_timeline_default(filter_timeline(query, account))
    end

    def favourites_map(status_ids, account_id)
      Favourite.select('status_id').where(status_id: status_ids).where(account_id: account_id).map { |f| [f.status_id, true] }.to_h
    end

    def reblogs_map(status_ids, account_id)
      select('reblog_of_id').where(reblog_of_id: status_ids).where(account_id: account_id).map { |s| [s.reblog_of_id, true] }.to_h
    end

    def reload_stale_associations!(cached_items)
      account_ids = []

      cached_items.each do |item|
        account_ids << item.account_id
        account_ids << item.reblog.account_id if item.reblog?
      end

      accounts = Account.where(id: account_ids.uniq).map { |a| [a.id, a] }.to_h

      cached_items.each do |item|
        item.account = accounts[item.account_id]
        item.reblog.account = accounts[item.reblog.account_id] if item.reblog?
      end
    end

    private

    def filter_timeline(query, account)
      blocked = Block.where(account: account).pluck(:target_account_id)
      query   = query.where('statuses.account_id NOT IN (?)', blocked) unless blocked.empty?
      query   = query.where('accounts.silenced = TRUE') if account.silenced?
      query
    end

    def filter_timeline_default(query)
      query.where('accounts.silenced = FALSE')
    end
  end

  before_validation do
    text.strip!
    self.reblog = reblog.reblog if reblog? && reblog.reblog?
    self.in_reply_to_account_id = thread.account_id if reply?
    self.visibility             = (account.locked? ? :private : :public) if visibility.nil?
  end

  private

  def filter_from_context?(status, account)
    account&.blocking?(status.account) || !status.permitted?(account)
  end
end
