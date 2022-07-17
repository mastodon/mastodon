# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags    = Extractor.extract_hashtags(status.text) if status.local?
    records = []

    Tag.find_or_create_by_names(tags) do |tag|
      status.tags << tag
      records << tag
      tag.update(last_status_at: status.created_at) if tag.last_status_at.nil? || (tag.last_status_at < status.created_at && tag.last_status_at < 12.hours.ago)
    end

    return unless status.distributable?

    status.account.featured_tags.where(tag_id: records.map(&:id)).each do |featured_tag|
      featured_tag.increment(status.created_at)
    end
  end
end
