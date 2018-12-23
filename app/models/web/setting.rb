# frozen_string_literal: true
# == Schema Information
#
# Table name: web_settings
#
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  id         :integer          not null, primary key
#  user_id    :integer
#

class Web::Setting < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: true
end
