# frozen_string_literal: true

class Api::V1::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }, except: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow }, only: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action :require_user!, except: [:show]
  before_action :set_account

  respond_to :json

  def show; end

  def follow
    FollowService.new.call(current_user.account, @account.acct)
    set_relationship
    render :relationship
  end

  def block
    BlockService.new.call(current_user.account, @account)

    @following       = { @account.id => false }
    @followed_by     = { @account.id => false }
    @blocking        = { @account.id => true }
    @requested       = { @account.id => false }
    @muting          = { @account.id => current_account.muting?(@account.id) }
    @domain_blocking = { @account.id => current_account.domain_blocking?(@account.domain) }

    render :relationship
  end

  def mute
    MuteService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  def unfollow
    UnfollowService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  def unblock
    UnblockService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  def unmute
    UnmuteService.new.call(current_user.account, @account)
    set_relationship
    render :relationship
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def set_relationship
    @following       = Account.following_map([@account.id], current_user.account_id)
    @followed_by     = Account.followed_by_map([@account.id], current_user.account_id)
    @blocking        = Account.blocking_map([@account.id], current_user.account_id)
    @muting          = Account.muting_map([@account.id], current_user.account_id)
    @requested       = Account.requested_map([@account.id], current_user.account_id)
    @domain_blocking = Account.domain_blocking_map([@account.id], current_user.account_id)
  end
end
