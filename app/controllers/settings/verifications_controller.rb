# frozen_string_literal: true

class Settings::VerificationsController < Settings::BaseController
  before_action :set_account

  def show
    @verified_links = @account.fields.select(&:verified?)
  end

  private

  def set_account
    @account = current_account
  end
end
