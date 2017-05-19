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

class AccountFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Account.alphabetic
    params.each do |key, value|
      scope.merge!(scope_for(key, value)) if value.present?
    end
    scope
  end

  private

  def scope_for(key, value)
    accounts = Account.arel_table

    case key.to_s
    when 'local'
      Account.local
    when 'remote'
      Account.remote
    when 'by_domain'
      Account.where(domain: value)
    when 'silenced'
      Account.silenced
    when 'recent'
      Account.recent
    when 'suspended'
      Account.suspended
    when 'username'
      Account.where(accounts[:username].matches("#{value}%"))
    when 'display_name'
      Account.where(accounts[:display_name].matches("#{value}%"))
    when 'email'
      users = User.arel_table
      Account.joins(:user).merge(User.where(users[:email].matches("#{value}%")))
    when 'ip'
      return Account.default_scoped unless valid_ip?(value)
      matches_ip = User.where(current_sign_in_ip: value).or(User.where(last_sign_in_ip: value))
      Account.joins(:user).merge(matches_ip)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def valid_ip?(value)
    IPAddr.new(value)
    true
  rescue IPAddr::InvalidAddressError
    false
  end
end
