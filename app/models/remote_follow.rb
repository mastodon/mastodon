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

class RemoteFollow
  include ActiveModel::Validations

  attr_accessor :acct, :addressable_template

  def initialize(attrs = {})
    @acct = attrs[:acct].gsub(/\A@/, '').strip unless attrs[:acct].nil?
  end

  def valid?
    populate_template
    errors.empty?
  end

  def subscribe_address_for(account)
    addressable_template.expand(uri: account.local_username_and_domain).to_s
  end

  private

  def populate_template
    if acct.blank? || redirect_url_link.nil? || redirect_url_link.template.nil?
      missing_resource_error
    else
      @addressable_template = Addressable::Template.new(redirect_uri_template)
    end
  end

  def redirect_uri_template
    redirect_url_link.template
  end

  def redirect_url_link
    acct_resource&.link('http://ostatus.org/schema/1.0/subscribe')
  end

  def acct_resource
    @_acct_resource ||= Goldfinger.finger("acct:#{acct}")
  rescue Goldfinger::Error
    missing_resource_error
    nil
  end

  def missing_resource_error
    errors.add(:acct, I18n.t('remote_follow.missing_resource'))
  end
end
