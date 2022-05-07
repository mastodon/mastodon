# frozen_string_literal: true

class Trends::Links < Trends::Base
  PREFIX = 'trending_links'

  self.default_options = {
    threshold: 5,
    review_threshold: 3,
    max_score_cooldown: 2.days.freeze,
    max_score_halflife: 8.hours.freeze,
    decay_threshold: 1,
  }

  def register(status, at_time = Time.now.utc)
    original_status = status.proper

    return unless (original_status.public_visibility? && status.public_visibility?) &&
                  !(original_status.account.silenced? || status.account.silenced?) &&
                  !(original_status.spoiler_text? || original_status.sensitive?)

    original_status.preview_cards.each do |preview_card|
      add(preview_card, status.account_id, at_time) if preview_card.appropriate_for_trends?
    end
  end

  def add(preview_card, account_id, at_time = Time.now.utc)
    preview_card.history.add(account_id, at_time)
    record_used_id(preview_card.id, at_time)
  end

  def refresh(at_time = Time.now.utc)
    preview_cards = PreviewCard.where(id: (recently_used_ids(at_time) + currently_trending_ids(false, -1)).uniq)
    calculate_scores(preview_cards, at_time)
  end

  def request_review
    preview_cards = PreviewCard.where(id: currently_trending_ids(false, -1))

    preview_cards.filter_map do |preview_card|
      next unless would_be_trending?(preview_card.id) && !preview_card.trendable? && preview_card.requires_review_notification?

      if preview_card.provider.nil?
        preview_card.provider = PreviewCardProvider.create(domain: preview_card.domain, requested_review_at: Time.now.utc)
      else
        preview_card.provider.touch(:requested_review_at)
      end

      preview_card
    end
  end

  protected

  def key_prefix
    PREFIX
  end

  def klass
    PreviewCard
  end

  private

  def calculate_scores(preview_cards, at_time)
    global_items = []
    locale_items = Hash.new { |h, key| h[key] = [] }

    preview_cards.each do |preview_card|
      expected  = preview_card.history.get(at_time - 1.day).accounts.to_f
      expected  = 1.0 if expected.zero?
      observed  = preview_card.history.get(at_time).accounts.to_f
      max_time  = preview_card.max_score_at
      max_score = preview_card.max_score
      max_score = 0 if max_time.nil? || max_time < (at_time - options[:max_score_cooldown])

      score = begin
        if expected > observed || observed < options[:threshold]
          0
        else
          ((observed - expected)**2) / expected
        end
      end

      if score > max_score
        max_score = score
        max_time  = at_time

        # Not interested in triggering any callbacks for this
        preview_card.update_columns(max_score: max_score, max_score_at: max_time)
      end

      decaying_score = max_score * (0.5**((at_time.to_f - max_time.to_f) / options[:max_score_halflife].to_f))

      next unless decaying_score >= options[:decay_threshold]

      global_items << { score: decaying_score, item:  preview_card }
      locale_items[preview_card.language] << { score: decaying_score, item: preview_card } if valid_locale?(preview_card.language)
    end

    replace_items('', global_items)

    Trends.available_locales.each do |locale|
      replace_items(":#{locale}", locale_items[locale])
    end
  end

  def filter_for_allowed_items(items)
    items.select { |item| item[:item].trendable? }
  end

  def would_be_trending?(id)
    score(id) > score_at_rank(options[:review_threshold] - 1)
  end
end
