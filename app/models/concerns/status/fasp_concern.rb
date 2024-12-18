# frozen_string_literal: true

module Status::FaspConcern
  extend ActiveSupport::Concern

  included do
    after_commit :announce_new_content_to_subscribed_fasp, on: :create
    after_commit :announce_updated_content_to_subscribed_fasp, on: :update
    after_commit :announce_deleted_content_to_subscribed_fasp, on: :destroy
    after_commit :announce_trends_to_subscribed_fasp, on: :create
  end

  private

  def announce_new_content_to_subscribed_fasp
    store_uri unless uri # TODO: solve this more elegantly
    Fasp::AnnounceContentLifecycleEventWorker.perform_async(uri, 'new')
  end

  def announce_updated_content_to_subscribed_fasp
    Fasp::AnnounceContentLifecycleEventWorker.perform_async(uri, 'update')
  end

  def announce_deleted_content_to_subscribed_fasp
    Fasp::AnnounceContentLifecycleEventWorker.perform_async(uri, 'delete')
  end

  def announce_trends_to_subscribed_fasp
    candidate_id, trend_source =
      if reblog_of_id
        [reblog_of_id, 'reblog']
      elsif in_reply_to_id
        [in_reply_to_id, 'reply']
      end
    Fasp::AnnounceTrendWorker.perform_async(candidate_id, trend_source) if candidate_id
  end
end
