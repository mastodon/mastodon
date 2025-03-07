# frozen_string_literal: true

class Fasp::RefreshTagTrendsService
  def call(provider, language)
    results = query_trends(provider, language)

    Fasp::TagTrend.transaction do
      Fasp::TagTrend.where(language:).delete_all

      (results['hashtags'] || []).each do |result|
        tag = Tag.find_or_create_by_names(result['name']).first

        Fasp::TagTrend.create!(
          fasp_provider: provider,
          tag:,
          language:,
          rank: result['rank'],
          allowed: tag.trendable?
        )

        fetch_examples(result['examples'])
      end
    end
  end

  private

  def fetch_examples(uris)
    uris.each { |u| FetchReplyWorker.perform_async(u) }
  end

  def query_trends(provider, language)
    params = { language:, withinLastHours: 4, maxCount: 20 }

    Fasp::Request.new(provider).get("/trends/v0/hashtags?#{params.to_query}")
  end
end
