# frozen_string_literal: true

class Api::ActivityPub::NotesController < Api::BaseController
  include Authorization

  before_action :set_status

  respond_to :activitystreams2

  def show
    authorize @status, :show?
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end
end
