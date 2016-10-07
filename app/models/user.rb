class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :account, inverse_of: :user
  accepts_nested_attributes_for :account

  validates :account, presence: true

  scope :prolific, -> { joins('inner join statuses on statuses.account_id = users.account_id').select('users.*, count(statuses.id) as statuses_count').group('users.id').order('statuses_count desc') }
  scope :recent,   -> { order('created_at desc') }
  scope :admins,   -> { where(admin: true) }

  has_settings do |s|
    s.key :notification_emails, defaults: { follow: true, reblog: true, favourite: true, mention: true }
  end
end
