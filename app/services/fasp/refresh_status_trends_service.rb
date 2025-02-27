# frozen_string_literal: true

class Fasp::RefreshStatusTrendsService
  def call(provider, language)
    results = query_trends(provider, language)

    Fasp::StatusTrend.transaction do
      Fasp::StatusTrend.where(language:).delete_all

      (results['content'] || []).each do |result|
        status = fetch_status(result['uri'])

        next if status.nil?

        Fasp::StatusTrend.create!(
          fasp_provider: provider,
          status:,
          language:,
          rank: result['rank'],
          allowed: !status.trendable?.nil?
        )
      end
    end
  end

  private

  def fetch_status(uri)
    ResolveURLService.new.call(uri)
  end

  def query_trends(provider, language)
    params = { language:, withinLastHours: 4, maxCount: 20 }

    Fasp::Request.new(provider).get("/trends/v0/content?#{params.to_query}")
  end
end
