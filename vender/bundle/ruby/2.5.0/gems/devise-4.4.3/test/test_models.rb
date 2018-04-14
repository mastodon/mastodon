# frozen_string_literal: true

class Configurable < User
  devise :database_authenticatable, :confirmable, :rememberable, :timeoutable, :lockable,
         stretches: 15, pepper: 'abcdef', allow_unconfirmed_access_for: 5.days,
         remember_for: 7.days, timeout_in: 15.minutes, unlock_in: 10.days
end

class WithValidation < Admin
  devise :database_authenticatable, :validatable, password_length: 2..6
end

class UserWithValidation < User
  validates_presence_of :username
end

class UserWithCustomHashing < User
  protected
  def password_digest(password)
    password.reverse
  end
end

class UserWithVirtualAttributes < User
  devise case_insensitive_keys: [:email, :email_confirmation]
  validates :email, presence: true, confirmation: { on: :create }
end

class Several < Admin
  devise :validatable
  devise :lockable
end

class Inheritable < Admin
end
