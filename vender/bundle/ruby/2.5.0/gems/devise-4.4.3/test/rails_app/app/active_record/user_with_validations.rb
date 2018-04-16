# frozen_string_literal: true

require 'shared_user'

class UserWithValidations < ActiveRecord::Base
  self.table_name = 'users'
  include Shim
  include SharedUser

  validates :email, presence: true
end

