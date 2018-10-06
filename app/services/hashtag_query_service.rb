# frozen_string_literal: true

class HashtagQueryService < BaseService
  def call(tag, params, account = nil, local = false)
    @query      = Status.as_tag_timeline(tag, account, local)
    @additional = Tag.where(name: Array(params[:tags]).map(&:downcase)) if params[:tags]
    @account    = account
    @local      = local

    if @additional.presence
      send params.fetch(:tag_mode, :any)
    else
      @query
    end
  end

  private

  def any
    @query.or(Status.as_tag_timeline(@additional, @account, @local)).distinct
  end

  def all
    @query.tagged_with_all(@additional)
  end

  def none
    @query.tagged_with_none(@additional)
  end
end
