# frozen_string_literal: true
# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ApplicationRecord
  has_and_belongs_to_many :statuses

  HASHTAG_NAME_RE = '[[:word:]_]*[[:alpha:]_·][[:word:]_]*'
  HASHTAG_RE = /(?:^|[^\/\)\w])#(#{HASHTAG_NAME_RE})/i

  validates :name, presence: true, uniqueness: true, format: { with: /\A#{HASHTAG_NAME_RE}\z/i }

  def to_param
    name
  end

  class << self
    def search_for(term, limit = 5)
      pattern = sanitize_sql_like(term.strip) + '%'
      Tag.where('lower(name) like lower(?)', pattern).order(:name).limit(limit)
    end
  end
end
