# frozen_string_literal: true

module Trends
  def self.table_name_prefix
    'trends_'
  end

  def self.links
    @links ||= Trends::Links.new
  end

  def self.tags
    @tags ||= Trends::Tags.new
  end

  def self.statuses
    @statuses ||= Trends::Statuses.new
  end

  def self.register!(status)
    [links, tags, statuses].each { |trend_type| trend_type.register(status) }
  end

  def self.refresh!
    [links, tags, statuses].each(&:refresh)
  end

  def self.request_review!
    return if skip_review? || !enabled?

    links_requiring_review    = links.request_review
    tags_requiring_review     = tags.request_review
    statuses_requiring_review = statuses.request_review

    return if links_requiring_review.empty? && tags_requiring_review.empty? && statuses_requiring_review.empty?

    User.those_who_can(:manage_taxonomies).includes(:account).find_each do |user|
      AdminMailer.with(recipient: user.account).new_trends(links_requiring_review, tags_requiring_review, statuses_requiring_review).deliver_later! if user.allows_trends_review_emails?
    end
  end

  def self.enabled?
    Setting.trends
  end

  def self.skip_review?
    Setting.trendable_by_default
  end

  def self.available_locales
    @available_locales ||= I18n.available_locales.map { |locale| locale.to_s.split(/[_-]/).first }.uniq
  end
end
