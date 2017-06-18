# frozen_string_literal: true

class FavouriteService < BaseService
  include Authorization

  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    authorize_with account, status, :show?

    favourite = Favourite.find_by(account: account, status: status)

    return favourite unless favourite.nil?

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
