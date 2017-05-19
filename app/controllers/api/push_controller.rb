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

class Api::PushController < ApiController
  def update
    response, status = process_push_request
    render plain: response, status: status
  end

  private

  def process_push_request
    case hub_mode
    when 'subscribe'
      Pubsubhubbub::SubscribeService.new.call(account_from_topic, hub_callback, hub_secret, hub_lease_seconds)
    when 'unsubscribe'
      Pubsubhubbub::UnsubscribeService.new.call(account_from_topic, hub_callback)
    else
      ["Unknown mode: #{hub_mode}", 422]
    end
  end

  def hub_mode
    params['hub.mode']
  end

  def hub_topic
    params['hub.topic']
  end

  def hub_callback
    params['hub.callback']
  end

  def hub_lease_seconds
    params['hub.lease_seconds']
  end

  def hub_secret
    params['hub.secret']
  end

  def account_from_topic
    if hub_topic.present? && local_domain? && account_feed_path?
      Account.find_local(hub_topic_params[:username])
    end
  end

  def hub_topic_params
    @_hub_topic_params ||= Rails.application.routes.recognize_path(hub_topic_uri.path)
  end

  def hub_topic_uri
    @_hub_topic_uri ||= Addressable::URI.parse(hub_topic).normalize
  end

  def local_domain?
    TagManager.instance.web_domain?(hub_topic_domain)
  end

  def hub_topic_domain
    hub_topic_uri.host + (hub_topic_uri.port ? ":#{hub_topic_uri.port}" : '')
  end

  def account_feed_path?
    hub_topic_params[:controller] == 'accounts' && hub_topic_params[:action] == 'show' && hub_topic_params[:format] == 'atom'
  end
end
