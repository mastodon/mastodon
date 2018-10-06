# frozen_string_literal: true

class HashtagQueryService < BaseService
  def call(tag, params, account = nil, local = false)
    @query      = Status.as_tag_timeline(tag, account, local)
    @additional = Tag.where(name: Array(params[:tags]).map(&:downcase)) if params[:tags]
    @mode       = params.fetch(:tag_mode, :any).to_sym
    @account    = account
    @local      = local

    return @query unless @additional.presence && [:all, :any, :none].include?(@mode)
    case @mode
    when :any then  @query.or(Status.as_tag_timeline(@additional, @account, @local)).distinct
    when :all then  @query.tagged_with_all(@additional)
    when :none then @query.tagged_with_none(@additional)
    end
  end
end
