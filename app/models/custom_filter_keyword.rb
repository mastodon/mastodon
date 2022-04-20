# frozen_string_literal: true
# == Schema Information
#
# Table name: custom_filter_keywords
#
#  id               :bigint           not null, primary key
#  custom_filter_id :bigint           not null
#  keyword          :text             default(""), not null
#  whole_word       :boolean          default(TRUE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CustomFilterKeyword < ApplicationRecord
  belongs_to :custom_filter

  validates :keyword, presence: true
end
