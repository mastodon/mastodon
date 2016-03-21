class Api::Accounts::LookupController < ApplicationController
  def index
    @accounts = Account.where(domain: nil).where(username: lookup_params)
  end

  private

  def lookup_params
    (params[:usernames] || '').split(',').map(&:strip)
  end
end
