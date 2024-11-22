# frozen_string_literal: true

class Disputes::StrikesController < Disputes::BaseController
  before_action :set_strike, only: [:show]

  def index
    @strikes = current_account.strikes.latest
  end

  def show
    authorize @strike, :show?

    @appeal = @strike.appeal || @strike.build_appeal
  end

  private

  def set_strike
    @strike = AccountWarning.find(params[:id])
  end
end
