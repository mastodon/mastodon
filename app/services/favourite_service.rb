class FavouriteService < BaseService
  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    favourite = Favourite.create!(account: account, status: status)
    account.ping!(account_url(account, format: 'atom'), [Rails.configuration.x.hub_url])
    return favourite if status.local?
    send_interaction_service.(favourite.stream_entry, status.account)
    favourite
  end

  private

  def send_interaction_service
    @send_interaction_service ||= SendInteractionService.new
  end
end
