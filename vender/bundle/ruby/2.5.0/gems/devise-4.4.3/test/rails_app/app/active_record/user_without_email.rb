# frozen_string_literal: true

require "shared_user_without_email"

class UserWithoutEmail < ActiveRecord::Base
  self.table_name = 'users'
  include Shim
  include SharedUserWithoutEmail
end

