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

class ImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  attr_reader :import

  def perform(import_id)
    @import = Import.find(import_id)

    case @import.type
    when 'blocking'
      process_blocks
    when 'following'
      process_follows
    when 'muting'
      process_mutes
    end

    @import.destroy
  end

  private

  def from_account
    @import.account
  end

  def import_contents
    Paperclip.io_adapters.for(@import.data).read
  end

  def import_rows
    CSV.new(import_contents).reject(&:blank?)
  end

  def process_mutes
    import_rows.each do |row|
      begin
        target_account = FollowRemoteAccountService.new.call(row.first)
        next if target_account.nil?
        MuteService.new.call(from_account, target_account)
      rescue Goldfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError
        next
      end
    end
  end

  def process_blocks
    import_rows.each do |row|
      begin
        target_account = FollowRemoteAccountService.new.call(row.first)
        next if target_account.nil?
        BlockService.new.call(from_account, target_account)
      rescue Goldfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError
        next
      end
    end
  end

  def process_follows
    import_rows.each do |row|
      begin
        FollowService.new.call(from_account, row.first)
      rescue Mastodon::NotPermittedError, ActiveRecord::RecordNotFound, Goldfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError
        next
      end
    end
  end
end
