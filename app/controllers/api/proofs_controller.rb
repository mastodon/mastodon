# frozen_string_literal: true

class Api::ProofsController < Api::BaseController
  include AccountOwnedConcern

  before_action :set_provider

  def index
    render json: @account, serializer: @provider.serializer_class
  end

  private

  def set_provider
    @provider = ProofProvider.find(params[:provider]) || raise(ActiveRecord::RecordNotFound)
  end

  def username_param
    params[:username]
  end
end
