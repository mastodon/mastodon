# frozen_string_literal: true

class FavouriteService < BaseService
  include Authorization

  # Favourite a status and notify remote user
  # @param [Account] account
  # @param [Status] status
  # @return [Favourite]
  def call(account, status)
    authorize_with account, status, :favourite?

    favourite = Favourite.find_by(account: account, status: status)

    return favourite unless favourite.nil?

    favourite = Favourite.create!(account: account, status: status)

    create_notification(favourite)
    bump_potential_friendship(account, status)

    favourite
  end

  private

  def create_notification(favourite)
    status = favourite.status

    if status.account.local?
      NotifyService.new.call(status.account, favourite)
    elsif status.account.ostatus?
      NotificationWorker.perform_async(build_xml(favourite), favourite.account_id, status.account_id)
    elsif status.account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(favourite), favourite.account_id, status.account.inbox_url)
    end
  end

  def bump_potential_friendship(account, status)
    return if account.following?(status.account_id)
    PotentialFriendshipTracker.record(account.id, status.account_id, :favourite)
  end

  def build_json(favourite)
    Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      favourite,
      serializer: ActivityPub::LikeSerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(favourite.account))
  end

  def build_xml(favourite)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.favourite_salmon(favourite))
  end
end
