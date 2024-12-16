# frozen_string_literal: true

module Status::FaspConcern
  extend ActiveSupport::Concern

  included do
    after_commit :announce_new_content_to_subscribed_fasp, on: :create
  end

  private

  def announce_new_content_to_subscribed_fasp
    store_uri unless uri # TODO: solve this more elegantly
    Fasp::AnnounceNewContentWorker.perform_async(uri)
  end
end
