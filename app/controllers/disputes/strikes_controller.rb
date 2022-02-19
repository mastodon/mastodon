# frozen_string_literal: true

class Disputes::StrikesController < Disputes::BaseController
  before_action :set_strike

  def show
    authorize @strike, :show?

    @appeal = @strike.appeal || @strike.build_appeal
  end

  private

  def set_strike
    @strike = AccountWarning.find(params[:id])
  end
end
