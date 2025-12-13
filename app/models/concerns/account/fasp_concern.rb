# frozen_string_literal: true

module Account::FaspConcern
  extend ActiveSupport::Concern

  included do
    after_commit :announce_new_account_to_subscribed_fasp, on: :create
    after_commit :announce_updated_account_to_subscribed_fasp, on: :update
    after_commit :announce_deleted_account_to_subscribed_fasp, on: :destroy
  end

  private

  def announce_new_account_to_subscribed_fasp
    return unless Mastodon::Feature.fasp_enabled?
    return unless discoverable?

    uri = ActivityPub::TagManager.instance.uri_for(self)
    Fasp::AnnounceAccountLifecycleEventWorker.perform_async(uri, 'new')
  end

  def announce_updated_account_to_subscribed_fasp
    return unless Mastodon::Feature.fasp_enabled?
    return unless discoverable? || saved_change_to_discoverable?

    uri = ActivityPub::TagManager.instance.uri_for(self)
    Fasp::AnnounceAccountLifecycleEventWorker.perform_async(uri, 'update')
  end

  def announce_deleted_account_to_subscribed_fasp
    return unless Mastodon::Feature.fasp_enabled?
    return unless discoverable?

    uri = ActivityPub::TagManager.instance.uri_for(self)
    Fasp::AnnounceAccountLifecycleEventWorker.perform_async(uri, 'delete')
  end
end
