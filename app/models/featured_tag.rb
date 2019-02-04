# frozen_string_literal: true
# == Schema Information
#
# Table name: featured_tags
#
#  id             :bigint(8)        not null, primary key
#  account_id     :bigint(8)
#  tag_id         :bigint(8)
#  statuses_count :bigint(8)        default(0), not null
#  last_status_at :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class FeaturedTag < ApplicationRecord
  belongs_to :account, inverse_of: :featured_tags, required: true
  belongs_to :tag, inverse_of: :featured_tags, required: true

  delegate :name, to: :tag, allow_nil: true

  def name=(str)
    self.tag = Tag.find_by(name: str.delete('#').mb_chars.downcase.to_s)
  end
end
