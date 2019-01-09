# frozen_string_literal: true

class HashtagQueryService < BaseService
  def call(tag, params, account = nil, local = false)
    tags = tags_for(Array(tag.name) | Array(params[:any])).pluck(:id)
    all  = tags_for(params[:all])
    none = tags_for(params[:none])

    Status.distinct
          .as_tag_timeline(tags, account, local)
          .tagged_with_all(all)
          .tagged_with_none(none)
  end

  private

  def tags_for(tags)
    Tag.where(name: tags.map(&:downcase)) if tags.presence
  end
end
