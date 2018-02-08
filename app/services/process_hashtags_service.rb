# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    if status.local? then
      tags = Extractor.extract_hashtags(status.text)

      if Rails.configuration.x.default_hashtag.present? && tags.empty? && status.visibility == 'public' && !status.reply? then
        tags << Rails.configuration.x.default_hashtag
        status.update(text: "#{status.text} ##{Rails.configuration.x.default_hashtag}")
      end
    end

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |tag|
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end

    status.update(sensitive: true) if tags.include?('nsfw')
  end
end
