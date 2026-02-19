# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_permissions
#
#  id              :bigint(8)        not null, primary key
#  account_id      :bigint(8)        not null
#  from_account_id :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class NotificationPermission < ApplicationRecord
  belongs_to :account
  belongs_to :from_account, class_name: 'Account'
end
