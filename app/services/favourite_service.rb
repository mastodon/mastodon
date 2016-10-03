class FavouriteService < BaseService
  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    favourite = Favourite.create!(account: account, status: status)
    account.ping!(account_url(account, format: 'atom'), [Rails.configuration.x.hub_url])

    if status.local?
      NotificationMailer.favourite(status, account).deliver_later unless status.account.blocking?(account)
    else
      NotificationWorker.perform_async(favourite.stream_entry.id, status.account_id)
    end

    favourite
  end
end
