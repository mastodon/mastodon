# frozen_string_literal: true

class UnfavouriteService < BaseService
  include StreamEntryRenderer

  def call(account, status)
    favourite = Favourite.find_by!(account: account, status: status)
    favourite.destroy!

    unless status.local?
      NotificationWorker.perform_async(stream_entry_to_xml(favourite.stream_entry), account.id, status.account_id)
    end

    favourite
  end
end
