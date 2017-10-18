# frozen_string_literal: true

class Admin::DomainWhitelistController < ApplicationController
  before_action :require_admin!

  layout 'admin'

  def index
    @unblocks = DomainWhitelist.paginate(page: params[:page], per_page: 40)
  end

  def create
  end
end
