# frozen_string_literal: true

module SharedAdmin
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :registerable,
           :timeoutable, :recoverable, :lockable, :confirmable,
           unlock_strategy: :time, lock_strategy: :none,
           allow_unconfirmed_access_for: 2.weeks, reconfirmable: true

    validates_length_of     :reset_password_token, minimum: 3, allow_blank: true
    if Devise::Test.rails51?
      validates_uniqueness_of :email, allow_blank: true, if: :will_save_change_to_email?
    else
      validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
    end
  end

  def raw_confirmation_token
    @raw_confirmation_token
  end
end
