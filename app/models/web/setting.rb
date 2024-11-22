# frozen_string_literal: true

# == Schema Information
#
# Table name: web_settings
#
#  id         :bigint(8)        not null, primary key
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#

class Web::Setting < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: true
end
