# frozen_string_literal: true

class HubPingWorker
  include Sidekiq::Worker
  include RoutingHelper

  def perform(account_id)
    account = Account.find(account_id)
    return unless account.local?
    OStatus2::Publication.new(account_url(account, format: 'atom'), [Rails.configuration.x.hub_url]).publish
  end
end
