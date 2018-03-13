# frozen_string_literal: true

class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    tags = Extractor.extract_hashtags(status.text) if status.local?

    tags.map { |str| str.mb_chars.downcase }.uniq(&:to_s).each do |tag|
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end

    status.update(sensitive: true) if tags.include?('nsfw')

    if status.local?
      status.account.recently_used_tags.where(tag: status.tags).delete_all
      last = status.account.recently_used_tags.order(:id).last
      index = last.nil? ? 0 : last.index

      status.tags.each do |tag|
        index += 1

        begin
          status.account.recently_used_tags.create! index: index, tag: tag
        rescue ActiveRecord::RecordNotUnique
          # The tag was used in some recent session and correctly recorded.
        end
      end

      status.account.recently_used_tags.where('index < ?', index - 1000).delete_all
    end
  end
end
