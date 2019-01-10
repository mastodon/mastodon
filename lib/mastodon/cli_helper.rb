# frozen_string_literal: true

dev_null = Logger.new('/dev/null')

Rails.logger                 = dev_null
ActiveRecord::Base.logger    = dev_null
HttpLog.configuration.logger = dev_null
Paperclip.options[:log]      = false
