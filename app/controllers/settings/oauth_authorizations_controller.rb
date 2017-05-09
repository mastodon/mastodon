# frozen_string_literal: true

class Settings::OauthAuthorizationsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @account = current_account
    @qiita_authorization = current_account.user.oauth_authorizations.find_by(provider: 'qiita')
  end
end
