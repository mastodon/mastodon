# frozen_string_literal: true

class TagsController < ApplicationController
  layout 'public'

  def show
    @tag      = Tag.find_by!(name: params[:id].downcase)
    @statuses = @tag.nil? ? [] : Status.as_tag_timeline(@tag, current_account, params[:local]).paginate_by_max_id(20, params[:max_id])
    @statuses = cache_collection(@statuses, Status)
  end
end
