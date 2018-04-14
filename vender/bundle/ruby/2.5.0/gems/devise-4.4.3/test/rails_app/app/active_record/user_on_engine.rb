# frozen_string_literal: true

require 'shared_user_without_omniauth'

class UserOnEngine < ActiveRecord::Base
  self.table_name = 'users'
  include Shim
  include SharedUserWithoutOmniauth
end
