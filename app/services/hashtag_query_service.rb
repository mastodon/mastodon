# frozen_string_literal: true

class HashtagQueryService < BaseService
  LIMIT_PER_MODE = 4

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

  def tags_for(names)
    Tag.matching_name(Array(names).take(LIMIT_PER_MODE)) if names.present?
  end
end
