class Tag < ApplicationRecord
  has_and_belongs_to_many :statuses

  HASHTAG_RE = /[?:^|\s|\.|>]#([[:word:]_]+)/i

  validates :name, presence: true, uniqueness: true

  def to_param
    name
  end
end
