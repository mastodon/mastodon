# frozen_string_literal: true

class Api::V1::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }, except: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow }, only: [:follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action :require_user!, except: [:show]
  before_action :set_account

  respond_to :json

  def show
    render json: @account, serializer: REST::AccountSerializer
  end

  def follow
    FollowService.new.call(current_user.account, @account.acct, reblogs: truthy_param?(:reblogs))

    options = @account.locked? ? {} : { following_map: { @account.id => { reblogs: truthy_param?(:reblogs) } }, requested_map: { @account.id => false } }

    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships(options)
  end

  def block
    BlockService.new.call(current_user.account, @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def mute
    MuteService.new.call(current_user.account, @account, notifications: truthy_param?(:notifications))
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def unfollow
    UnfollowService.new.call(current_user.account, @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def unblock
    UnblockService.new.call(current_user.account, @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def unmute
    UnmuteService.new.call(current_user.account, @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def relationships(**options)
    AccountRelationshipsPresenter.new([@account.id], current_user.account_id, options)
  end
end
