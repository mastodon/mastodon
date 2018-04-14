# frozen_string_literal: true
require "kaminari/activerecord/version"
require 'active_support/lazy_load_hooks'

ActiveSupport.on_load :active_record do
  require 'kaminari/core'
  require 'kaminari/activerecord/active_record_extension'
  ::ActiveRecord::Base.send :include, Kaminari::ActiveRecordExtension
end
