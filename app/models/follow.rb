class Follow < ActiveRecord::Base
  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  after_create do
    self.account.stream_entries.create!(activity: self)
  end
end
