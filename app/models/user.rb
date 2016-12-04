# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :account, inverse_of: :user
  accepts_nested_attributes_for :account

  validates :account, presence: true
  validates :locale, inclusion: I18n.available_locales.map(&:to_s), unless: 'locale.nil?'
  validates :email, email: true

  scope :prolific, -> { joins('inner join statuses on statuses.account_id = users.account_id').select('users.*, count(statuses.id) as statuses_count').group('users.id').order('statuses_count desc') }
  scope :recent,   -> { order('id desc') }
  scope :admins,   -> { where(admin: true) }

  has_settings do |s|
    s.key :notification_emails, defaults: { follow: false, reblog: false, favourite: false, mention: false }
    s.key :interactions, defaults: { must_be_follower: false, must_be_following: false }
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
