# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags    = Extractor.extract_hashtags(status.text) if status.local?
    records = []

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |name|
      tag = Tag.where(name: name).first_or_create(name: name)

      status.tags << tag
      records << tag

      TrendingTags.record_use!(tag, status.account, status.created_at) if status.public_visibility?
    end

    return unless status.public_visibility? || status.unlisted_visibility?

    status.account.featured_tags.where(tag_id: records.map(&:id)).each do |featured_tag|
      featured_tag.increment(status.created_at)
    end
  end
end
