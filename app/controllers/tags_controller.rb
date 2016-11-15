# frozen_string_literal: true

class TagsController < ApplicationController
  layout 'public'

  def show
    @statuses = Tag.find_by!(name: params[:id].downcase).statuses.order('id desc').with_includes.with_counters.paginate(page: params[:page], per_page: 10)
  end
end
