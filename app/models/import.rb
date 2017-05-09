# frozen_string_literal: true
#
# Mastodon, a GNU Social-compatible microblogging server
# Copyright (C) 2016-2017 Eugen Rochko & al (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# == Schema Information
#
# Table name: imports
#
#  id                :integer          not null, primary key
#  account_id        :integer          not null
#  type              :integer          not null
#  approved          :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  data_file_name    :string
#  data_content_type :string
#  data_file_size    :integer
#  data_updated_at   :datetime
#

class Import < ApplicationRecord
  FILE_TYPES = ['text/plain', 'text/csv'].freeze

  self.inheritance_column = false

  belongs_to :account, required: true

  enum type: [:following, :blocking, :muting]

  validates :type, presence: true

  has_attached_file :data, url: '/system/:hash.:extension', hash_secret: ENV['PAPERCLIP_SECRET']
  validates_attachment_content_type :data, content_type: FILE_TYPES
end
