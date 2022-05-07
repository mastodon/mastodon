# frozen_string_literal: true

class Trends::Tags < Trends::Base
  PREFIX = 'trending_tags'

  self.default_options = {
    threshold: 5,
    review_threshold: 3,
    max_score_cooldown: 2.days.freeze,
    max_score_halflife: 4.hours.freeze,
    decay_threshold: 1,
  }

  def register(status, at_time = Time.now.utc)
    return unless !status.reblog? && status.public_visibility? && !status.account.silenced?

    status.tags.each do |tag|
      add(tag, status.account_id, at_time) if tag.usable?
    end
  end

  def add(tag, account_id, at_time = Time.now.utc)
    tag.history.add(account_id, at_time)
    record_used_id(tag.id, at_time)
  end

  def refresh(at_time = Time.now.utc)
    tags = Tag.where(id: (recently_used_ids(at_time) + currently_trending_ids(false, -1)).uniq)
    calculate_scores(tags, at_time)
  end

  def request_review
    tags = Tag.where(id: currently_trending_ids(false, -1))

    tags.filter_map do |tag|
      next unless would_be_trending?(tag.id) && !tag.trendable? && tag.requires_review_notification?

      tag.touch(:requested_review_at)
      tag
    end
  end

  protected

  def key_prefix
    PREFIX
  end

  def klass
    Tag
  end

  private

  def calculate_scores(tags, at_time)
    items = []

    tags.each do |tag|
      expected  = tag.history.get(at_time - 1.day).accounts.to_f
      expected  = 1.0 if expected.zero?
      observed  = tag.history.get(at_time).accounts.to_f
      max_time  = tag.max_score_at
      max_score = tag.max_score
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
        tag.update_columns(max_score: max_score, max_score_at: max_time)
      end

      decaying_score = max_score * (0.5**((at_time.to_f - max_time.to_f) / options[:max_score_halflife].to_f))

      next unless decaying_score >= options[:decay_threshold]

      items << { score: decaying_score, item: tag }
    end

    replace_items('', items)
  end

  def filter_for_allowed_items(items)
    items.select { |item| item[:item].trendable? }
  end

  def would_be_trending?(id)
    score(id) > score_at_rank(options[:review_threshold] - 1)
  end
end
