# frozen_string_literal: true

class TagsController < ApplicationController
  layout 'public'

  def show
    @tag      = Tag.find_by!(name: params[:id].downcase)
    @statuses = if @tag.nil?
                  []
                else
                  Status.as_tag_timeline(@tag,
                                         account: current_account,
                                         local_only: params[:local],
                                         limit: 20,
                                         max_id: params[:max_id])
                end
    @statuses = cache_collection(@statuses, Status)
  end
end
