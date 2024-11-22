# frozen_string_literal: true

class Trends::Links < Trends::Base
  PREFIX = 'trending_links'

  BATCH_SIZE = 100

  self.default_options = {
    threshold: 5,
    review_threshold: 3,
    max_score_cooldown: 2.days.freeze,
    max_score_halflife: 8.hours.freeze,
    decay_threshold: 1,
  }

  class Query < Trends::Query
    def filtered_for!(account)
      @account = account
      self
    end

    def filtered_for(account)
      clone.filtered_for!(account)
    end

    def to_arel
      scope = PreviewCard.joins(:trend).reorder(score: :desc)
      scope = scope.reorder(language_order_clause.desc, score: :desc) if preferred_languages.present?
      scope = scope.merge(PreviewCardTrend.allowed) if @allowed
      scope = scope.offset(@offset) if @offset.present?
      scope = scope.limit(@limit) if @limit.present?
      scope
    end

    private

    def language_order_clause
      Arel::Nodes::Case.new.when(PreviewCardTrend.arel_table[:language].in(preferred_languages)).then(1).else(0)
    end

    def preferred_languages
      if @account&.chosen_languages.present?
        @account.chosen_languages
      else
        @locale
      end
    end
  end

  def register(status, at_time = Time.now.utc)
    original_status = status.proper

    return unless (original_status.public_visibility? && status.public_visibility?) &&
                  !(original_status.account.silenced? || status.account.silenced?) &&
                  !(original_status.spoiler_text? || original_status.sensitive?)

    add(original_status.preview_card, status.account_id, at_time) if original_status.preview_card&.appropriate_for_trends?
  end

  def add(preview_card, account_id, at_time = Time.now.utc)
    preview_card.history.add(account_id, at_time)
    record_used_id(preview_card.id, at_time)
  end

  def query
    Query.new(key_prefix, klass)
  end

  def refresh(at_time = Time.now.utc)
    # First, recalculate scores for links that were trending previously. We split the queries
    # to avoid having to load all of the IDs into Ruby just to send them back into Postgres
    PreviewCard.where(id: PreviewCardTrend.select(:preview_card_id)).find_in_batches(batch_size: BATCH_SIZE) do |preview_cards|
      calculate_scores(preview_cards, at_time)
    end

    # Then, calculate scores for links that were used today. There are potentially some
    # duplicate items here that we might process one more time, but that should be fine
    PreviewCard.where(id: recently_used_ids(at_time)).find_in_batches(batch_size: BATCH_SIZE) do |preview_cards|
      calculate_scores(preview_cards, at_time)
    end

    # Now that all trends have up-to-date scores, and all the ones below the threshold have
    # been removed, we can recalculate their positions
    PreviewCardTrend.recalculate_ordered_rank
  end

  def request_review
    PreviewCardTrend.locales.flat_map do |language|
      score_at_threshold  = PreviewCardTrend.where(language: language).allowed.by_rank.ranked_below(options[:review_threshold]).first&.score || 0
      preview_card_trends = PreviewCardTrend.where(language: language).not_allowed.joins(:preview_card)

      preview_card_trends.filter_map do |trend|
        preview_card = trend.preview_card

        next unless trend.score > score_at_threshold && !preview_card.trendable? && preview_card.requires_review_notification?

        if preview_card.provider.nil?
          preview_card.provider = PreviewCardProvider.create(domain: preview_card.domain, requested_review_at: Time.now.utc)
        else
          preview_card.provider.touch(:requested_review_at)
        end

        preview_card
      end
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
    items = preview_cards.map do |preview_card|
      expected  = preview_card.history.get(at_time - 1.day).accounts.to_f
      expected  = 1.0 if expected.zero?
      observed  = preview_card.history.get(at_time).accounts.to_f
      max_time  = preview_card.max_score_at
      max_score = preview_card.max_score
      max_score = 0 if max_time.nil? || max_time < (at_time - options[:max_score_cooldown])

      score = if expected > observed || observed < options[:threshold]
                0
              else
                ((observed - expected)**2) / expected
              end

      if score > max_score
        max_score = score
        max_time  = at_time

        # Not interested in triggering any callbacks for this
        preview_card.update_columns(max_score: max_score, max_score_at: max_time)
      end

      decaying_score = if max_score.zero? || !valid_locale?(preview_card.language)
                         0
                       else
                         max_score * (0.5**((at_time.to_f - max_time.to_f) / options[:max_score_halflife].to_f))
                       end

      [decaying_score, preview_card]
    end

    to_insert = items.filter { |(score, _)| score >= options[:decay_threshold] }
    to_delete = items.filter { |(score, _)| score < options[:decay_threshold] }

    PreviewCardTrend.upsert_all(to_insert.map { |(score, preview_card)| { preview_card_id: preview_card.id, score: score, language: preview_card.language, allowed: preview_card.trendable? || false } }, unique_by: :preview_card_id) if to_insert.any?
    PreviewCardTrend.where(preview_card_id: to_delete.map { |(_, preview_card)| preview_card.id }).delete_all if to_delete.any?
  end
end
