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

    User.those_who_can(:manage_taxonomies).includes(:account).find_each do |user|
      links    = user.allows_trending_links_review_emails? ? links_requiring_review : []
      tags     = user.allows_trending_tags_review_emails? ? tags_requiring_review : []
      statuses = user.allows_trending_statuses_review_emails? ? statuses_requiring_review : []
      next if links.empty? && tags.empty? && statuses.empty?

      AdminMailer.new_trends(user.account, links, tags, statuses).deliver_later!
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
