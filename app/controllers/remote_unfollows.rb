# frozen_string_literal: true

class RemoteUnfollowsController < ApplicationController
  layout 'modal'

  before_action :authenticate_user!
  before_action :set_body_classes

  def create
    @account = unfollow_attempt.try(:target_account)

    if @account.nil?
      render :error
    else
      render :success
    end
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    render :error
  end

  private

  def unfollow_attempt
    username, domain = acct_without_prefix.split('@')
    UnfollowService.new.call(current_account, Account.find_remote!(username, domain))
  end

  def acct_without_prefix
    acct_params.gsub(/\Aacct:/, '')
  end

  def acct_params
    params.fetch(:acct, '')
  end

  def set_body_classes
    @body_classes = 'modal-layout'
  end
end
