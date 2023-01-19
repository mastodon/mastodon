# frozen_string_literal: true

class Hello::VerifiedController < ApplicationController
  include WebAppControllerConcern

  before_action :require_authenticated_user!

  def index
    @mastodon_builder_url = Hello.mastodon_builder_url
    @account = current_account
  end

  def require_authenticated_user!
    render json: { error: 'An authenticated user is required' }, status: 401 unless current_user
  end
end
