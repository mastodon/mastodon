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
require 'csv'

class Export
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def to_blocked_accounts_csv
    to_csv account.blocking
  end

  def to_muted_accounts_csv
    to_csv account.muting
  end

  def to_following_accounts_csv
    to_csv account.following
  end

  def total_storage
    account.media_attachments.sum(:file_file_size)
  end

  def total_follows
    account.following.count
  end

  def total_blocks
    account.blocking.count
  end

  def total_mutes
    account.muting.count
  end

  private

  def to_csv(accounts)
    CSV.generate do |csv|
      accounts.each do |account|
        csv << [(account.local? ? account.local_username_and_domain : account.acct)]
      end
    end
  end
end
