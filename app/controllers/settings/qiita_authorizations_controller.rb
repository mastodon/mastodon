# frozen_string_literal: true

class Settings::QiitaAuthorizationsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @account = current_account
    @qiita_authorization = current_account.user.qiita_authorization
  end
end
