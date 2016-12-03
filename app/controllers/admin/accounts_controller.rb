# frozen_string_literal: true

class Admin::AccountsController < ApplicationController
  before_action :require_admin!

  layout 'public'

  def index
    @accounts = Account.order('domain ASC, username ASC').paginate(page: params[:page], per_page: 40)
  end

  def show
    @account = Account.find(params[:id])
  end
end
