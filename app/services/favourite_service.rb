# frozen_string_literal: true

class FavouriteService < BaseService
  include Authorization
  include Payloadable

  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    authorize_with account, status, :favourite?

    favourite = Favourite.find_by(account: account, status: status)

    return favourite unless favourite.nil?

    favourite = Favourite.create!(account: account, status: status)

    Trends.statuses.register(status)

    create_notification(favourite)
    bump_potential_friendship(account, status)

    favourite
  end

  private

  def create_notification(favourite)
    status = favourite.status

    if status.account.local?
      LocalNotificationWorker.perform_async(status.account_id, favourite.id, 'Favourite', 'favourite')
    elsif status.account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(favourite), favourite.account_id, status.account.inbox_url)
    end
  end

  def bump_potential_friendship(account, status)
    ActivityTracker.increment('activity:interactions')
    return if account.following?(status.account_id)
    PotentialFriendshipTracker.record(account.id, status.account_id, :favourite)
  end

  def build_json(favourite)
    Oj.dump(serialize_payload(favourite, ActivityPub::LikeSerializer))
  end
end
