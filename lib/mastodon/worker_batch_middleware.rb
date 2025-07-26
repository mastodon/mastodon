# frozen_string_literal: true

class Mastodon::WorkerBatchMiddleware
  def call(_worker, msg, _queue, _redis_pool = nil)
    if (batch = Thread.current[:batch])
      batch.add_jobs([msg['jid']])
    end

    yield
  end
end
