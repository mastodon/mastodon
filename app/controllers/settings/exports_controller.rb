# frozen_string_literal: true

class Settings::ExportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_account

  def show; end

  private

  def set_account
    @account = current_user.account
  end
end
