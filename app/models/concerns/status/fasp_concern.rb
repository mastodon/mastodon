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
    return unless account_indexable? && public_visibility?

    store_uri unless uri # TODO: solve this more elegantly
    Fasp::AnnounceContentLifecycleEventWorker.perform_async(uri, 'new')
  end

  def announce_updated_content_to_subscribed_fasp
    return unless account_indexable? && public_visibility_or_just_changed?

    Fasp::AnnounceContentLifecycleEventWorker.perform_async(uri, 'update')
  end

  def announce_deleted_content_to_subscribed_fasp
    return unless account_indexable? && public_visibility?

    Fasp::AnnounceContentLifecycleEventWorker.perform_async(uri, 'delete')
  end

  def announce_trends_to_subscribed_fasp
    return unless account_indexable?

    candidate_id, trend_source =
      if reblog_of_id
        [reblog_of_id, 'reblog']
      elsif in_reply_to_id
        [in_reply_to_id, 'reply']
      end
    Fasp::AnnounceTrendWorker.perform_async(candidate_id, trend_source) if candidate_id
  end

  def public_visibility_or_just_changed?
    public_visibility? || visibility_previously_was == 'public'
  end
end
