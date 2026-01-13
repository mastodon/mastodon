# frozen_string_literal: true

class Fasp::BackfillWorker < Fasp::BaseWorker
  sidekiq_options retry: 5

  def perform(backfill_request_id)
    backfill_request = Fasp::BackfillRequest.find(backfill_request_id)

    with_provider(backfill_request.fasp_provider) do
      announce(backfill_request)

      backfill_request.advance!
    end
  rescue ActiveRecord::RecordNotFound
    # ignore missing backfill requests
  end

  private

  def announce(backfill_request)
    Fasp::Request.new(backfill_request.fasp_provider).post('/data_sharing/v0/announcements', body: {
      source: {
        backfillRequest: {
          id: backfill_request.id.to_s,
        },
      },
      category: backfill_request.category,
      objectUris: backfill_request.next_uris,
      moreObjectsAvailable: backfill_request.more_objects_available?,
    })
  end
end
