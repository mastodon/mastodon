# == Schema Information
#
# Table name: web_push_subscriptions
#
#  id         :integer          not null, primary key
#  account_id :integer
#  endpoint   :string
#  key_p256dh :string
#  key_auth   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WebPushSubscription < ApplicationRecord
end
