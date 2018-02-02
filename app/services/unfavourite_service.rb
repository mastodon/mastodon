# frozen_string_literal: true

class UnfavouriteService < BaseService
  def call(account, status)
    favourite = Favourite.find_by!(account: account, status: status)
    favourite.destroy!
    create_notification(favourite) unless status.local?
    favourite
  end

  private

  def create_notification(favourite)
    status = favourite.status

    if status.account.ostatus?
      NotificationWorker.perform_async(build_xml(favourite), favourite.account_id, status.account_id)
    elsif status.account.activitypub?
      ActivityPub::DeliveryWorker.perform_async(build_json(favourite), favourite.account_id, status.account.inbox_url)
    end
  end

  def build_json(favourite)
    Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(
      favourite,
      serializer: ActivityPub::UndoLikeSerializer,
      adapter: ActivityPub::Adapter
    ).as_json).sign!(favourite.account))
  end

  def build_xml(favourite)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.unfavourite_salmon(favourite))
  end
end
