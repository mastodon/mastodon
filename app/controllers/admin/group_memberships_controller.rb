# frozen_string_literal: true

module Admin
  class GroupMembershipsController < BaseController
    before_action :set_group

    PER_PAGE = 40

    def index
      authorize @group, :show?

      @accounts = GroupMembershipFilter.new(@group, filter_params).results.includes(:account_stat, user: [:ips, :invite_request]).page(params[:page]).per(PER_PAGE)
      @form     = Form::AccountBatch.new
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def filter_params
      params.slice(*GroupMembershipFilter::KEYS).permit(*GroupMembershipFilter::KEYS)
    end
  end
end
