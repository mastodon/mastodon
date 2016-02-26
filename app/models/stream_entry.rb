class StreamEntry < ActiveRecord::Base
  belongs_to :account, inverse_of: :stream_entries
  belongs_to :activity, polymorphic: true

  validates :account, :activity, presence: true

  def object_type
    targeted? ? :activity : self.activity.object_type
  end

  def verb
    self.activity.verb
  end

  def targeted?
    [:follow, :share, :favorite].include? verb
  end

  def target
    self.activity.target
  end

  def title
    self.activity.title
  end

  def content
    self.activity.content
  end

  def threaded?
    verb == :favorite || object_type == :comment
  end

  def thread
    self.activity.thread
  end

  def mentions
    self.activity.mentions
  end
end
