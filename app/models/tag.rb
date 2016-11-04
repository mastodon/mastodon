class Tag < ApplicationRecord
  HASHTAG_RE = /[?:^|\s|\.|>]#([[:word:]_]+)/i

  validates :name, presence: true, uniqueness: true
end
