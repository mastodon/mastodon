# frozen_string_literal: true

class HashtagQueryService < BaseService
  def call(tag, params, account = nil, local = false)
    any  = tags_for(params[:any])
    all  = tags_for(params[:all])
    none = tags_for(params[:none])

    @query = Status.as_tag_timeline(tag, account, local)
                   .tagged_with_all(all)
                   .tagged_with_none(none)
    @query = @query.distinct.or(self.class.new.call(any, params.except(:any), account, local).distinct) if any
    @query
  end

  private

  def tags_for(tags)
    Tag.where(name: tags.map(&:downcase)) if tags.presence
  end
end
