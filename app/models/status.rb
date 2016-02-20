class Status < ActiveRecord::Base
  belongs_to :account, inverse_of: :statuses
end
