# frozen_string_literal: true

class Admin::DomainBlocksController < ApplicationController
  before_action :require_admin!

  layout 'admin'

  def index
    @blocks = DomainBlock.paginate(page: params[:page], per_page: 40)
  end

  def create
  end
end
