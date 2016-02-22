class Status < ActiveRecord::Base
  belongs_to :account, inverse_of: :statuses

  validates :account, presence: true

  def verb
    :post
  end

  def object_type
    :note
  end

  def content
    self.text
  end

  def title
    content.truncate(80, omission: "...")
  end

  after_create do
    self.account.stream_entries.create!(activity: self)
  end
end
