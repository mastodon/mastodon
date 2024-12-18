# frozen_string_literal: true

module Favourite::FaspConcern
  extend ActiveSupport::Concern

  included do
    after_commit :announce_trends_to_subscribed_fasp, on: :create
  end

  private

  def announce_trends_to_subscribed_fasp
    Fasp::AnnounceTrendWorker.perform_async(status_id, 'favourite')
  end
end
