# frozen_string_literal: true

class FavouriteService < BaseService
  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    raise Mastodon::NotPermittedError unless status.permitted?(account)

    favourite = Favourite.create!(account: account, status: status)

    if status.local?
      NotifyService.new.call(favourite.status.account, favourite)
    else
      NotificationWorker.perform_async(build_xml(favourite), account.id, status.account_id)
    end

    favourite
  end

  private

  def build_xml(favourite)
    AtomSerializer.render(AtomSerializer.new.favourite_salmon(favourite))
  end
end
