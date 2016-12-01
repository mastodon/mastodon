# frozen_string_literal: true

class TagsController < ApplicationController
  layout 'public'

  def show
    @statuses = Tag.find_by!(name: params[:id].downcase).statuses.order('id desc').paginate_by_max_id(20, params[:max_id] || nil)
  	@statuses = cache_collection(@statuses, Status)
  end
end
