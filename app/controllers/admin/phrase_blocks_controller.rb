# frozen_string_literal: true

module Admin
  class PhraseBlocksController < BaseController
    before_action :set_phrase_block, only: [:edit, :update, :destroy]

    def index
      authorize :phrase_block, :index?
      @phrase_blocks = PhraseBlock.order(id: :desc).page(params[:page])
    end

    def new
      authorize :phrase_block, :create?
      @phrase_block = PhraseBlock.new
    end

    def edit
      authorize @phrase_block, :update?
    end

    def create
      authorize :phrase_block, :create?

      @phrase_block = PhraseBlock.new(resource_params)

      if @phrase_block.save
        log_action :create, @phrase_block
        redirect_to admin_phrase_blocks_path, notice: I18n.t('admin.phrase_blocks.created_msg')
      else
        render :new
      end
    end

    def update
      authorize @phrase_block, :update?
      if @phrase_block.update(resource_params)
        log_action :update, @phrase_block

        redirect_to admin_phrase_blocks_path, notice: I18n.t('admin.phrase_blocks.updated_msg')
      else
        render action: :edit
      end
    end

    def destroy
      authorize @phrase_block, :destroy?
      @phrase_block.destroy!
      log_action :destroy, @phrase_block
      redirect_to admin_phrase_blocks_path, notice: I18n.t('admin.phrase_blocks.destroyed_msg')
    end

    private

    def set_phrase_block
      @phrase_block = PhraseBlock.find(params[:id])
    end

    def resource_params
      params.require(:phrase_block).permit(:phrase, :filter_type, :whole_word)
    end
  end
end
