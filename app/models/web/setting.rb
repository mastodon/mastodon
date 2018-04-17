# frozen_string_literal: true
# == Schema Information
#
# Table name: web_settings
#
#  id         :integer          not null, primary key
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#

class Web::Setting < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: true
end
