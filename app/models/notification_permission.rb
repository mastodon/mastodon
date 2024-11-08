# frozen_string_literal: true

class NotificationPermission < ApplicationRecord
  belongs_to :account
  belongs_to :from_account, class_name: 'Account'
end
