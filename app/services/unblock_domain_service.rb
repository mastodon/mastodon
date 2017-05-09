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

class UnblockDomainService < BaseService
  attr_accessor :domain_block

  def call(domain_block, retroactive)
    @domain_block = domain_block
    process_retroactive_updates if retroactive
    domain_block.destroy
  end

  def process_retroactive_updates
    blocked_accounts.in_batches.update_all(update_options)
  end

  def blocked_accounts
    Account.where(domain: domain_block.domain)
  end

  def update_options
    { domain_block_impact => false }
  end

  def domain_block_impact
    domain_block.silence? ? :silenced : :suspended
  end
end
