# frozen_string_literal: true
# == Schema Information
#
# Table name: profile_changes
#
#  id                  :integer          not null, primary key
#  account_id          :integer          not null
#  avatar_file_name    :string
#  avatar_content_type :string
#  avatar_file_size    :integer
#  avatar_updated_at   :datetime
#  display_name        :string           default(""), not null
#

class ProfileChange < ApplicationRecord
  include AccountAvatar

  belongs_to :account, required: true

  has_many :notifications, as: :activity, dependent: :destroy

  validates :account_id, presence: true, uniqueness: true
end
