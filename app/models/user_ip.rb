# frozen_string_literal: true

# == Schema Information
#
# Table name: user_ips
#
#  user_id :bigint(8)        primary key
#  ip      :inet
#  used_at :datetime
#

class UserIp < ApplicationRecord
  self.primary_key = :user_id

  belongs_to :user

  def readonly?
    true
  end
end
