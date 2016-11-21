# frozen_string_literal: true

class Status < ApplicationRecord
  include Paginable
  include Streamable

  belongs_to :account, -> { with_counters }, inverse_of: :statuses

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

  scope :with_counters, -> { select('statuses.*, (select count(r.id) from statuses as r where r.reblog_of_id = statuses.id) as reblogs_count, (select count(f.id) from favourites as f where f.status_id = statuses.id) as favourites_count') }
  scope :with_includes, -> { includes(:account, :media_attachments, :tags, :stream_entry, mentions: :account, reblog: [:account, mentions: :account], thread: :account) }

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

  def reblogs_count
    attributes['reblogs_count'] || reblogs.count
  end

  def favourites_count
    attributes['favourites_count'] || favourites.count
  end

  def ancestors(account = nil)
    ids      = (Status.find_by_sql(['WITH RECURSIVE search_tree(id, in_reply_to_id, path) AS (SELECT id, in_reply_to_id, ARRAY[id] FROM statuses WHERE id = ? UNION ALL SELECT statuses.id, statuses.in_reply_to_id, path || statuses.id FROM search_tree JOIN statuses ON statuses.id = search_tree.in_reply_to_id WHERE NOT statuses.id = ANY(path)) SELECT id FROM search_tree ORDER BY path DESC', id]) - [self]).pluck(:id)
    statuses = Status.where(id: ids).with_counters.with_includes.group_by(&:id)
    results  = ids.map { |id| statuses[id].first }
    results  = results.reject { |status| account.blocking?(status.account) } unless account.nil?

    results
  end

  def descendants(account = nil)
    ids      = (Status.find_by_sql(['WITH RECURSIVE search_tree(id, path) AS (SELECT id, ARRAY[id] FROM statuses WHERE id = ? UNION ALL SELECT statuses.id, path || statuses.id FROM search_tree JOIN statuses ON statuses.in_reply_to_id = search_tree.id WHERE NOT statuses.id = ANY(path)) SELECT id FROM search_tree ORDER BY path', id]) - [self]).pluck(:id)
    statuses = Status.where(id: ids).with_counters.with_includes.group_by(&:id)
    results  = ids.map { |id| statuses[id].first }
    results  = results.reject { |status| account.blocking?(status.account) } unless account.nil?

    results
  end

  class << self
    def as_home_timeline(account)
      where(account: [account] + account.following).with_includes.with_counters
    end

    def as_mentions_timeline(account)
      where(id: Mention.where(account: account).pluck(:status_id)).with_includes.with_counters
    end

    def as_public_timeline(account = nil)
      query = joins('LEFT OUTER JOIN accounts ON statuses.account_id = accounts.id').where('accounts.silenced = FALSE')
      query = filter_timeline(query, account) unless account.nil?

      query.with_includes.with_counters
    end

    def as_tag_timeline(tag, account = nil)
      query = tag.statuses
                 .joins('LEFT OUTER JOIN accounts ON statuses.account_id = accounts.id')
                 .where('accounts.silenced = FALSE')

      query = filter_timeline(query, account) unless account.nil?

      query.with_includes.with_counters
    end

    def favourites_map(status_ids, account_id)
      Favourite.select('status_id').where(status_id: status_ids).where(account_id: account_id).map { |f| [f.status_id, true] }.to_h
    end

    def reblogs_map(status_ids, account_id)
      select('reblog_of_id').where(reblog_of_id: status_ids).where(account_id: account_id).map { |s| [s.reblog_of_id, true] }.to_h
    end

    private

    def filter_timeline(query, account)
      blocked = Block.where(account: account).pluck(:target_account_id)
      return query if blocked.empty?

      query
        .joins('LEFT OUTER JOIN statuses AS parents ON statuses.in_reply_to_id = parents.id')
        .joins('LEFT OUTER JOIN statuses AS reblogs ON statuses.reblog_of_id = reblogs.id')
        .where('statuses.account_id NOT IN (?)', blocked)
        .where('(parents.id IS NULL OR parents.account_id NOT IN (?))', blocked)
        .where('(reblogs.id IS NULL OR reblogs.account_id NOT IN (?))', blocked)
    end
  end

  before_validation do
    text.strip!
  end
end
