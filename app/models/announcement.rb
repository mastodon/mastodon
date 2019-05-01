# == Schema Information
#
# Table name: announcements
#
#  id         :bigint(8)        not null, primary key
#  body       :string           default(""), not null
#  order      :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Announcement < ApplicationRecord
  has_many :links, class_name: 'AnnouncementLink', inverse_of: :announcement

  accepts_nested_attributes_for :links, reject_if: proc { |attrs| attrs['url'].blank? && attrs['text'].blank? }, allow_destroy: true
  default_scope { includes(:links).order(order: :desc) }

  validates :body, presence: true
end
