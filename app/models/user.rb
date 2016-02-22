class User < ActiveRecord::Base
  belongs_to :account, inverse_of: :user
end
