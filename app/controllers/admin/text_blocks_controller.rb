# frozen_string_literal: true

module Admin
  class TextBlocksController < BaseController
    before_action :set_new_text_block, only: [:index, :create]
    before_action :find_and_set_text_block, only: [:show, :update, :destroy]
    before_action :authorize_text_block

    def index
      page = params[:page]
      @text_block = TextBlock.new if page.nil?
      @text_blocks = TextBlock.recent.page(page)
    end

    def show; end

    def create
      if @text_block.save
        log_action :create, @text_block
        redirect_to({ action: :index }, notice: I18n.t('admin.text_blocks.created'))
      else
        @text_blocks = TextBlock.page(0)
        flash.now[:alert] = @text_block.errors.full_messages.first
        render :index
      end
    end

    def update
      if @text_block.update text_block_params
        log_action :update, @text_block
        redirect_to({ action: :index }, notice: I18n.t('admin.text_blocks.updated'))
      else
        flash.now[:alert] = @text_block.errors.full_messages.first
        render :show
      end
    end

    def destroy
      if @text_block.destroy
        log_action :destroy, @text_block
        flash[:notice] = I18n.t('admin.text_blocks.destroyed')
      else
        flash[:alert] = @text_block.errors.full_messages.first
      end

      redirect_to action: :index
    end

    private

    def authorize_text_block
      authorize @text_block
    end

    def set_new_text_block
      @text_block = TextBlock.new(text_block_params)
    end

    def find_and_set_text_block
      @text_block = TextBlock.find(params.require(:id))
    end

    def text_block_params
      params[:text_block]&.permit(:text, :severity)
    end
  end
end
