# frozen_string_literal: true

class Trends::Statuses < Trends::Base
  PREFIX = 'trending_statuses'

  self.default_options = {
    threshold: 5,
    review_threshold: 3,
    score_halflife: 2.hours.freeze,
    decay_threshold: 0.3,
  }

  class Query < Trends::Query
    def filtered_for!(account)
      @account = account
      self
    end

    def filtered_for(account)
      clone.filtered_for!(account)
    end

    private

    def apply_scopes(scope)
      if @account.nil?
        scope
      else
        scope.not_excluded_by_account(@account).not_domain_blocked_by_account(@account)
      end
    end
  end

  def register(status, at_time = Time.now.utc)
    add(status.proper, status.account_id, at_time) if eligible?(status.proper)
  end

  def add(status, _account_id, at_time = Time.now.utc)
    # We rely on the total reblogs and favourites count, so we
    # don't record which account did the what and when here

    record_used_id(status.id, at_time)
  end

  def query
    Query.new(key_prefix, klass)
  end

  def refresh(at_time = Time.now.utc)
    statuses = Status.where(id: (recently_used_ids(at_time) + currently_trending_ids(false, -1)).uniq).includes(:account, :media_attachments)
    calculate_scores(statuses, at_time)
  end

  def request_review
    statuses = Status.where(id: currently_trending_ids(false, -1)).includes(:account)

    statuses.filter_map do |status|
      next unless would_be_trending?(status.id) && !status.trendable? && status.requires_review_notification?

      status.account.touch(:requested_review_at)
      status
    end
  end

  protected

  def key_prefix
    PREFIX
  end

  def klass
    Status
  end

  private

  def eligible?(status)
    status.public_visibility? && status.account.discoverable? && !status.account.silenced? && !status.account.sensitized? && status.spoiler_text.blank? && !status.sensitive? && !status.reply?
  end

  def calculate_scores(statuses, at_time)
    global_items = []
    locale_items = Hash.new { |h, key| h[key] = [] }

    statuses.each do |status|
      expected  = 1.0
      observed  = (status.reblogs_count + status.favourites_count).to_f

      score = begin
        if expected > observed || observed < options[:threshold]
          0
        else
          ((observed - expected)**2) / expected
        end
      end

      decaying_score = score * (0.5**((at_time.to_f - status.created_at.to_f) / options[:score_halflife].to_f))

      next unless decaying_score >= options[:decay_threshold]

      global_items << { score: decaying_score, item: status }
      locale_items[status.language] << { account_id: status.account_id, score: decaying_score, item: status } if valid_locale?(status.language)
    end

    replace_items('', global_items)

    Trends.available_locales.each do |locale|
      replace_items(":#{locale}", locale_items[locale])
    end
  end

  def filter_for_allowed_items(items)
    # Show only one status per account, pick the one with the highest score
    # that's also eligible to trend

    items.group_by { |item| item[:account_id] }.values.filter_map { |account_items| account_items.select { |item| item[:item].trendable? && item[:item].account.discoverable? }.max_by { |item| item[:score] } }
  end

  def would_be_trending?(id)
    score(id) > score_at_rank(options[:review_threshold] - 1)
  end
end
