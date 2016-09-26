class UnfavouriteService < BaseService
  def call(account, status)
    favourite = Favourite.find_by!(account: account, status: status)
    favourite.destroy!

    unless status.local?
      NotificationWorker.perform_async(favourite.stream_entry.id, status.account_id)
    end

    favourite
  end
end
