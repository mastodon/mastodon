# frozen_string_literal: true

class Api::V1::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }, except: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow }, only: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action :require_user!, except: [:show]
  before_action :set_account
  before_action :set_relationship_map, except: [:show, :block]

  respond_to :json

  def show; end

  def follow
    FollowService.new.call(current_user.account, @account.acct)
    render :relationship
  end

  def block
    BlockService.new.call(current_user.account, @account)
    @relationship_map = BlockedRelationshipMap.new(current_account, @account)
    render :relationship
  end

  def mute
    MuteService.new.call(current_user.account, @account)
    render :relationship
  end

  def unfollow
    UnfollowService.new.call(current_user.account, @account)
    render :relationship
  end

  def unblock
    UnblockService.new.call(current_user.account, @account)
    render :relationship
  end

  def unmute
    UnmuteService.new.call(current_user.account, @account)
    render :relationship
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def set_relationship_map
    @relationship_map = RelationshipMap.new([@account.id], current_user.account)
  end
end
