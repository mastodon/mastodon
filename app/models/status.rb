class Status < ActiveRecord::Base
  belongs_to :account, inverse_of: :statuses

  after_create do
    self.account.stream_entries.create!(activity: self)
  end
end
