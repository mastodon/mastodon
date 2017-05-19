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

class Api::SubscriptionsController < ApiController
  before_action :set_account
  respond_to :txt

  def show
    if @account.subscription(api_subscription_url(@account.id)).valid?(params['hub.topic'])
      @account.update(subscription_expires_at: Time.now.utc + (params['hub.lease_seconds'] || 86_400).to_i.seconds)
      render plain: HTMLEntities.new.encode(params['hub.challenge']), status: 200
    else
      head 404
    end
  end

  def update
    body = request.body.read
    subscription = @account.subscription(api_subscription_url(@account.id))

    if subscription.verify(body, request.headers['HTTP_X_HUB_SIGNATURE'])
      ProcessingWorker.perform_async(@account.id, body.force_encoding('UTF-8'))
    end

    head 200
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
