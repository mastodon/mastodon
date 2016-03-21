class Api::Accounts::LookupController < ApiController
  before_action :doorkeeper_authorize!
  respond_to    :json

  def index
    @accounts = Account.where(domain: nil).where(username: lookup_params)
  end

  private

  def lookup_params
    (params[:usernames] || '').split(',').map(&:strip)
  end
end
