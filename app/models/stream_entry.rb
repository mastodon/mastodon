class StreamEntry < ActiveRecord::Base
  belongs_to :account, inverse_of: :stream_entries
  belongs_to :activity, polymorphic: true

  validates :account, :activity, presence: true

  scope :with_includes,      -> { includes(:activity) }
  scope :paginate_by_max_id, -> (limit, max_id) { order('id desc').limit(limit).where(max_id.nil? ? '1=1' : ['id < ?', max_id]) }

  def object_type
    orphaned? ? :activity : (targeted? ? :activity : self.activity.object_type)
  end

  def verb
    orphaned? ? :delete : self.activity.verb
  end

  def targeted?
    [:follow, :share, :favorite].include? verb
  end

  def target
    orphaned? ? nil : self.activity.target
  end

  def title
    orphaned? ? nil : self.activity.title
  end

  def content
    orphaned? ? nil : self.activity.content
  end

  def threaded?
    verb == :favorite || object_type == :comment
  end

  def thread
    orphaned? ? nil : self.activity.thread
  end

  def mentions
    orphaned? ? [] : self.activity.mentions
  end

  private

  def orphaned?
    self.activity.nil?
  end
end
