# frozen_string_literal: true

class Fasp::RefreshPreviewCardTrendsService
  def call(provider, language)
    results = query_trends(provider, language)

    Fasp::PreviewCardTrend.transaction do
      Fasp::PreviewCardTrend.where(language:).delete_all

      (results['links'] || []).each do |link|
        preview_card = fetch_preview_card(link['url'])

        next unless preview_card

        Fasp::PreviewCardTrend.create!(
          fasp_provider: provider,
          preview_card:,
          language:,
          rank: link['rank'],
          allowed: !preview_card.trendable?.nil?
        )

        fetch_examples(link['examples'])
      end
    end
  end

  private

  def fetch_preview_card(url)
    FetchLinkCardForURLService.new.call(url)
  end

  def fetch_examples(uris)
    uris.each { |u| FetchReplyWorker.perform_async(u) }
  end

  def query_trends(provider, language)
    params = { language:, withinLastHours: 4, maxCount: 20 }

    Fasp::Request.new(provider).get("/trends/v0/links?#{params.to_query}")
  end
end
