# frozen_string_literal: true

class Api::V1::AccountsController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:accounts' }, except: [:create, :follow, :unfollow, :block, :unblock, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow, :'write:follows' }, only: [:follow, :unfollow]
  before_action -> { doorkeeper_authorize! :follow, :'write:mutes' }, only: [:mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow, :'write:blocks' }, only: [:block, :unblock]
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:create]

  before_action :require_user!, except: [:show, :create]
  before_action :set_account, except: [:create]
  before_action :check_account_suspension, only: [:show]
  before_action :check_enabled_registrations, only: [:create]

  respond_to :json

  def show
    render json: @account, serializer: REST::AccountSerializer
  end

  def create
    token    = AppSignUpService.new.call(doorkeeper_token.application, account_params)
    response = Doorkeeper::OAuth::TokenResponse.new(token)

    headers.merge!(response.headers)

    self.response_body = Oj.dump(response.body)
    self.status        = response.status
  end

  def follow
    FollowService.new.call(current_user.account, @account, reblogs: truthy_param?(:reblogs))

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

  def check_account_suspension
    gone if @account.suspended?
  end

  def account_params
    params.permit(:username, :email, :password, :agreement, :locale)
  end

  def check_enabled_registrations
    forbidden if single_user_mode? || !Setting.open_registrations
  end
end
