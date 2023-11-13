# frozen_string_literal: true

class Redirect::AccountsController < ApplicationController
  vary_by 'Accept-Language'

  before_action :set_account
  before_action :set_app_body_class

  def show
    @redirect_path = ActivityPub::TagManager.instance.url_for(@account)

    render 'redirects/show', layout: 'application'
  end

  private

  def set_app_body_class
    @body_classes = 'app-body'
  end

  def set_account
    @account = Account.find(params[:id])
    not_found if @account.local?
  end
end
