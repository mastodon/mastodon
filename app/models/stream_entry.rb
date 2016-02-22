class StreamEntry < ActiveRecord::Base
  belongs_to :account, inverse_of: :stream_entries
  belongs_to :activity, polymorphic: true

  def object_type
    case self.activity_type
    when 'Status'
      :note
    when 'Follow'
      :person
    end
  end

  def verb
    case self.activity_type
    when 'Status'
      :post
    when 'Follow'
      :follow
    end
  end

  def target
    case self.activity_type
    when 'Follow'
      self.activity.target_account
    end
  end

  def content
    self.activity.text if self.activity_type == 'Status'
  end
end
