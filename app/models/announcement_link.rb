# == Schema Information
#
# Table name: announcement_links
#
#  id              :bigint(8)        not null, primary key
#  announcement_id :bigint(8)        not null
#  text            :string           default(""), not null
#  url             :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AnnouncementLink < ApplicationRecord
  belongs_to :announcement, inverse_of: :links

  validates :text, presence: true
  validates :url, presence: true
end
