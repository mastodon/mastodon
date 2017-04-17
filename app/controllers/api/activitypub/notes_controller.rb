# frozen_string_literal: true

class Api::Activitypub::NotesController < ApiController
  before_action :set_status

  respond_to :activitystreams2

  def show
    forbidden unless @status.permitted?
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end
end
