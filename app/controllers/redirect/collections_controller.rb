# frozen_string_literal: true

class Redirect::CollectionsController < Redirect::BaseController
  private

  def set_resource
    @resource = Collection.find(params[:id])
    not_found if @resource.local? || @resource&.account&.suspended?
  end
end
