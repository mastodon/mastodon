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
# Table name: follows
#
#  id                :integer          not null, primary key
#  account_id        :integer          not null
#  target_account_id :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Follow < ApplicationRecord
  include Paginable

  belongs_to :account, counter_cache: :following_count, required: true

  belongs_to :target_account,
             class_name: 'Account',
             counter_cache: :followers_count,
             required: true

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }
end
