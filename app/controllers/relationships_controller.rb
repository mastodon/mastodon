# frozen_string_literal: true

class RelationshipsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_accounts, only: :show
  before_action :set_body_classes

  helper_method :following_relationship?, :followed_by_relationship?, :mutual_relationship?

  def show
    @form = Form::AccountBatch.new
  end

  def update
    @form = Form::AccountBatch.new(form_account_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    # Do nothing
  ensure
    redirect_to relationships_path(current_params)
  end

  private

  def set_accounts
    @accounts = relationships_scope.page(params[:page]).per(40)
  end

  def relationships_scope
    scope = begin
      if following_relationship?
        current_account.following.eager_load(:account_stat).reorder(nil)
      else
        current_account.followers.eager_load(:account_stat).reorder(nil)
      end
    end

    scope.merge!(Follow.recent)             if params[:order].blank? || params[:order] == 'recent'
    scope.merge!(Account.by_recent_status)  if params[:order] == 'active'
    scope.merge!(mutual_relationship_scope) if mutual_relationship?
    scope.merge!(moved_account_scope)       if params[:status] == 'moved'
    scope.merge!(primary_account_scope)     if params[:status] == 'primary'
    scope.merge!(by_domain_scope)           if params[:by_domain].present?
    scope.merge!(dormant_account_scope)     if params[:activity] == 'dormant'

    scope
  end

  def mutual_relationship_scope
    Account.where(id: current_account.following)
  end

  def moved_account_scope
    Account.where.not(moved_to_account_id: nil)
  end

  def primary_account_scope
    Account.where(moved_to_account_id: nil)
  end

  def dormant_account_scope
    AccountStat.where(last_status_at: nil).or(AccountStat.where(AccountStat.arel_table[:last_status_at].lt(1.month.ago)))
  end

  def by_domain_scope
    Account.where(domain: params[:by_domain])
  end

  def form_account_batch_params
    params.require(:form_account_batch).permit(:action, account_ids: [])
  end

  def following_relationship?
    params[:relationship].blank? || params[:relationship] == 'following'
  end

  def mutual_relationship?
    params[:relationship] == 'mutual'
  end

  def followed_by_relationship?
    params[:relationship] == 'followed_by'
  end

  def current_params
    params.slice(:page, :status, :relationship, :by_domain, :activity, :order).permit(:page, :status, :relationship, :by_domain, :activity, :order)
  end

  def action_from_button
    if params[:unfollow]
      'unfollow'
    elsif params[:remove_from_followers]
      'remove_from_followers'
    elsif params[:block_domains]
      'block_domains'
    end
  end

  def set_body_classes
    @body_classes = 'admin'
  end
end
