class StreamEntry < ActiveRecord::Base
  include Paginable

  belongs_to :account, inverse_of: :stream_entries
  belongs_to :activity, polymorphic: true

  validates :account, :activity, presence: true

  scope :with_includes, -> { includes(:activity) }

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
