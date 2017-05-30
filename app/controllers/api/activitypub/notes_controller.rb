# frozen_string_literal: true

class Api::Activitypub::NotesController < ApiController
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
