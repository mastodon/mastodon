# frozen_string_literal: true

class Trends::Statuses < Trends::Base
  PREFIX = 'trending_statuses'

  self.default_options = {
    threshold: 5,
    review_threshold: 3,
    score_halflife: 2.hours.freeze,
  }

  class Query < Trends::Query
    def filtered_for(account)
      @account = account
      self
    end

    private

    def apply_scopes(scope)
      scope.includes(:account)
    end

    def perform_queries
      return super if @account.nil?

      statuses        = super
      account_ids     = statuses.map(&:account_id)
      account_domains = statuses.map(&:account_domain)

      preloaded_relations = {
        blocking: Account.blocking_map(account_ids, @account.id),
        blocked_by: Account.blocked_by_map(account_ids, @account.id),
        muting: Account.muting_map(account_ids, @account.id),
        following: Account.following_map(account_ids, @account.id),
        domain_blocking_by_domain: Account.domain_blocking_map_by_domain(account_domains, @account.id),
      }

      statuses.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
    end
  end

  def register(status, at_time = Time.now.utc)
    add(status.proper, status.account_id, at_time) if eligible?(status)
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
    trim_older_items
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
    original_status = status.proper

    original_status.public_visibility? &&
      original_status.account.discoverable? && !original_status.account.silenced? &&
      original_status.spoiler_text.blank? && !original_status.sensitive? && !original_status.reply?
  end

  def calculate_scores(statuses, at_time)
    redis.pipelined do
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

        add_to_and_remove_from_subsets(status.id, decaying_score, {
          all: true,
          allowed: status.trendable? && status.account.discoverable?,
        })

        next if status.language.blank?

        add_to_and_remove_from_subsets(status.id, decaying_score, {
          "all:#{status.language}" => true,
          "allowed:#{status.language}" => status.trendable? && status.account.discoverable?,
        })
      end
    end
  end

  def would_be_trending?(id)
    score(id) > score_at_rank(options[:review_threshold] - 1)
  end
end
