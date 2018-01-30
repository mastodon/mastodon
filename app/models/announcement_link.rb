# frozen_string_literal: true
# == Schema Information
#
# Table name: announcement_links
#
#  id              :integer          not null, primary key
#  announcement_id :integer          not null
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
