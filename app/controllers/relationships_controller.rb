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
    redirect_to relationships_path(filter_params)
  end

  private

  def set_accounts
    @accounts = RelationshipFilter.new(current_account, filter_params).results.page(params[:page]).per(40)
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

  def filter_params
    params.slice(:page, *RelationshipFilter::KEYS).permit(:page, *RelationshipFilter::KEYS)
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
