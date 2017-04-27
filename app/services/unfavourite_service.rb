# frozen_string_literal: true

class UnfavouriteService < BaseService
  def call(account, status)
    favourite = Favourite.find_by!(account: account, status: status)
    favourite.destroy!

    NotificationWorker.perform_async(build_xml(favourite), account.id, status.account_id) unless status.local?

    favourite
  end

  private

  def build_xml(favourite)
    AtomSerializer.render(AtomSerializer.new.unfavourite_salmon(favourite))
  end
end
