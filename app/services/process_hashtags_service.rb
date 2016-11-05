class ProcessHashtagsService < BaseService
  def call(status, tags = [])
    if status.local?
      tags = status.text.scan(Tag::HASHTAG_RE).map(&:first)
    end

    tags.map(&:downcase).uniq.each do |tag|
      status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
    end
  end
end
