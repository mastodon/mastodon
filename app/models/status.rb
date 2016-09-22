class Status < ApplicationRecord
  include Paginable
  include Streamable

  belongs_to :account, inverse_of: :statuses

  belongs_to :thread, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :replies
  belongs_to :reblog, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblogs

  has_many :favourites, inverse_of: :status, dependent: :destroy
  has_many :reblogs, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblog, dependent: :destroy
  has_many :replies, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :thread
  has_many :mentions, dependent: :destroy
  has_many :media_attachments, dependent: :destroy

  validates :account, presence: true
  validates :uri, uniqueness: true, unless: 'local?'
  validates :text, presence: true, if: Proc.new { |s| s.local? && !s.reblog? }

  scope :with_counters, -> { select('statuses.*, (select count(r.id) from statuses as r where r.reblog_of_id = statuses.id) as reblogs_count, (select count(f.id) from favourites as f where f.status_id = statuses.id) as favourites_count') }
  scope :with_includes, -> { includes(:account, :media_attachments, :stream_entry, mentions: :account, reblog: [:account, mentions: :account], thread: :account) }

  def local?
    self.uri.nil?
  end

  def reblog?
    !self.reblog_of_id.nil?
  end

  def reply?
    !self.in_reply_to_id.nil?
  end

  def verb
    reblog? ? :share : :post
  end

  def object_type
    reply? ? :comment : :note
  end

  def content
    reblog? ? self.reblog.text : self.text
  end

  def target
    self.reblog
  end

  def title
    content
  end

  def reblogs_count
    self.attributes['reblogs_count'] || self.reblogs.count
  end

  def favourites_count
    self.attributes['favourites_count'] || self.favourites.count
  end

  def ancestors
    ids      = (Status.find_by_sql(['WITH RECURSIVE search_tree(id, in_reply_to_id, path) AS (SELECT id, in_reply_to_id, ARRAY[id] FROM statuses WHERE id = ? UNION ALL SELECT statuses.id, statuses.in_reply_to_id, path || statuses.id FROM search_tree JOIN statuses ON statuses.id = search_tree.in_reply_to_id WHERE NOT statuses.id = ANY(path)) SELECT id FROM search_tree ORDER BY path DESC', self.id]) - [self]).pluck(:id)
    statuses = Status.where(id: ids).with_counters.with_includes.group_by(&:id)

    ids.map { |id| statuses[id].first }
  end

  def descendants
    ids      = (Status.find_by_sql(['WITH RECURSIVE search_tree(id, path) AS (SELECT id, ARRAY[id] FROM statuses WHERE id = ? UNION ALL SELECT statuses.id, path || statuses.id FROM search_tree JOIN statuses ON statuses.in_reply_to_id = search_tree.id WHERE NOT statuses.id = ANY(path)) SELECT id FROM search_tree ORDER BY path', self.id]) - [self]).pluck(:id)
    statuses = Status.where(id: ids).with_counters.with_includes.group_by(&:id)

    ids.map { |id| statuses[id].first }
  end

  def self.as_home_timeline(account)
    self.where(account: [account] + account.following).with_includes.with_counters
  end

  def self.as_mentions_timeline(account)
    self.where(id: Mention.where(account: account).pluck(:status_id)).with_includes.with_counters
  end

  def self.favourites_map(status_ids, account_id)
    Favourite.where(status_id: status_ids).where(account_id: account_id).map { |f| [f.status_id, true] }.to_h
  end

  def self.reblogs_map(status_ids, account_id)
    self.where(reblog_of_id: status_ids).where(account_id: account_id).map { |s| [s.reblog_of_id, true] }.to_h
  end

  before_validation do
    self.text.strip!
  end
end
