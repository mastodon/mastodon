# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags = status.text.scan(Tag::HASHTAG_RE).map(&:first) if status.local?

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |tag|
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end

    status.update(sensitive: true) if tags.include?('nsfw')
  end
end
