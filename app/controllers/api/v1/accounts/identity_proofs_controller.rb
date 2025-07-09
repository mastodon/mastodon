# frozen_string_literal: true

class Api::V1::Accounts::IdentityProofsController < Api::BaseController
  include DeprecationConcern

  deprecate_api '2022-03-30'

  before_action :require_user!
  before_action :set_account

  def index
    render json: []
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end
end
