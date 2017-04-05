# frozen_string_literal: true

class Admin::DomainBlocksController < ApplicationController
  before_action :require_admin!

  layout 'admin'

  def index
    @blocks = DomainBlock.paginate(page: params[:page], per_page: 40)
  end

  def new
    @domain_block = DomainBlock.new
  end

  def create
    @domain_block = DomainBlock.new(resource_params)

    if @domain_block.save
      DomainBlockWorker.perform_async(@domain_block.id)
      redirect_to admin_domain_blocks_path, notice: 'Domain block is now being processed'
    else
      render action: :new
    end
  end

  private

  def resource_params
    params.require(:domain_block).permit(:domain, :severity)
  end
end
