# frozen_string_literal: true

class Admin::UsernameBlocksController < Admin::BaseController
  before_action :set_username_block, only: [:edit, :update]

  def index
    authorize :username_block, :index?
    @username_blocks = UsernameBlock.order(username: :asc).page(params[:page])
    @form = Form::UsernameBlockBatch.new
  end

  def batch
    authorize :username_block, :index?

    @form = Form::UsernameBlockBatch.new(form_username_block_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    flash[:alert] = I18n.t('admin.username_blocks.no_username_block_selected')
  rescue Mastodon::NotPermittedError
    flash[:alert] = I18n.t('admin.username_blocks.not_permitted')
  ensure
    redirect_to admin_username_blocks_path
  end

  def new
    authorize :username_block, :create?
    @username_block = UsernameBlock.new(exact: true)
  end

  def edit
    authorize @username_block, :update?
  end

  def create
    authorize :username_block, :create?

    @username_block = UsernameBlock.new(resource_params)

    if @username_block.save
      log_action :create, @username_block
      redirect_to admin_username_blocks_path, notice: I18n.t('admin.username_blocks.created_msg')
    else
      render :new
    end
  end

  def update
    authorize @username_block, :update?

    if @username_block.update(resource_params)
      log_action :update, @username_block
      redirect_to admin_username_blocks_path, notice: I18n.t('admin.username_blocks.updated_msg')
    else
      render :new
    end
  end

  private

  def set_username_block
    @username_block = UsernameBlock.find(params[:id])
  end

  def form_username_block_batch_params
    params
      .expect(form_username_block_batch: [username_block_ids: []])
  end

  def resource_params
    params
      .expect(username_block: [:username, :comparison, :allow_with_approval])
  end

  def action_from_button
    'delete' if params[:delete]
  end
end
