# frozen_string_literal: true

module Admin
  class GroupsController < BaseController
    before_action :set_group, except: [:index, :batch]
    before_action :require_remote_group!, only: [:redownload]

    def index
      authorize :group, :index?

      @groups = filtered_groups.page(params[:page])
      @form   = Form::GroupBatch.new
    end

    def batch
      authorize :group, :index?

      @form = Form::GroupBatch.new(form_group_batch_params)
      @form.current_account = current_account
      @form.action = action_from_button
      @form.select_all_matching = params[:select_all_matching]
      @form.query = filtered_groups
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.groups.no_groups_selected')
    ensure
      redirect_to admin_groups_path(filter_params)
    end

    def show
      authorize @group, :show?

      @deletion_request = @group.deletion_request
      @domain_block     = DomainBlock.rule_for(@group.domain)
    end

    def suspend
      authorize @group, :suspend?
      @group.suspend!
      Admin::GroupSuspensionWorker.perform_async(@group.id)
      log_action :suspend, @group
      redirect_to admin_group_path(@group.id), notice: I18n.t('admin.groups.suspended_msg')
    end

    def unsuspend
      authorize @group, :unsuspend?
      @group.unsuspend!
      Admin::GroupUnsuspensionWorker.perform_async(@group.id)
      log_action :unsuspend, @group
      redirect_to admin_group_path(@group.id), notice: I18n.t('admin.groups.unsuspended_msg')
    end

    def remove_avatar
      authorize @group, :remove_avatar?

      @group.avatar = nil
      @group.save!

      log_action :remove_avatar, @group

      redirect_to admin_group_path(@group.id), notice: I18n.t('admin.groups.removed_avatar_msg')
    end

    def remove_header
      authorize @group, :remove_header?

      @group.header = nil
      @group.save!

      log_action :remove_header, @group

      redirect_to admin_group_path(@group.id), notice: I18n.t('admin.groups.removed_header_msg')
    end

    private

    def set_group
      @group = Group.find(params[:id])
    end

    def require_remote_group!
      redirect_to admin_group_path(@group.id) if @group.local?
    end

    def filtered_groups
      GroupFilter.new(filter_params.with_defaults(order: 'recent')).results
    end

    def filter_params
      params.slice(:page, *GroupFilter::KEYS).permit(:page, *GroupFilter::KEYS)
    end

    def form_group_batch_params
      params.require(:form_group_batch).permit(:action, group_ids: [])
    end

    def action_from_button
      if params[:suspend]
        'suspend'
      end
    end
  end
end
