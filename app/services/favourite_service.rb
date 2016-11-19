# frozen_string_literal: true

class FavouriteService < BaseService
  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    favourite = Favourite.create!(account: account, status: status)
    HubPingWorker.perform_async(account.id)

    if status.local?
      NotifyService.new.call(status.account, favourite)
    else
      NotificationWorker.perform_async(favourite.stream_entry.id, status.account_id)
    end

    favourite
  end
end
