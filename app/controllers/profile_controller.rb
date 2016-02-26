class ProfileController < ApplicationController
  before_action :set_account

  def show
  end

  def entry
    @entry = @account.stream_entries.find(params[:id])
    @type  = @entry.activity_type.downcase
  end

  private

  def set_account
    @account = Account.find_by!(username: params[:name], domain: nil)
  end
end
