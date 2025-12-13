# frozen_string_literal: true

class Api::V1::AccountsController < Api::BaseController
  include RegistrationHelper

  before_action -> { authorize_if_got_token! :read, :'read:accounts' }, except: [:create, :follow, :unfollow, :remove_from_followers, :block, :unblock, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:follows' }, only: [:follow, :unfollow, :remove_from_followers]
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:mutes' }, only: [:mute, :unmute]
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:blocks' }, only: [:block, :unblock]
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:create]

  before_action :require_user!, except: [:index, :show, :create]
  before_action :require_client_credentials!, only: [:create]
  before_action :set_account, except: [:index, :create]
  before_action :set_accounts, only: [:index]
  before_action :check_account_approval, except: [:index, :create]
  before_action :check_account_confirmation, except: [:index, :create]
  before_action :check_enabled_registrations, only: [:create]
  before_action :check_accounts_limit, only: [:index]
  before_action :check_following_self, only: [:follow]

  skip_before_action :require_authenticated_user!, only: :create

  override_rate_limit_headers :follow, family: :follows

  def index
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def show
    cache_if_unauthenticated!
    render json: @account, serializer: REST::AccountSerializer
  end

  def create
    token    = AppSignUpService.new.call(doorkeeper_token.application, request.remote_ip, account_params)
    response = Doorkeeper::OAuth::TokenResponse.new(token)

    headers.merge!(response.headers)

    self.response_body = Oj.dump(response.body)
    self.status        = response.status
  rescue ActiveRecord::RecordInvalid => e
    render json: ValidationErrorFormatter.new(e, 'account.username': :username, 'invite_request.text': :reason).as_json, status: 422
  end

  def follow
    follow  = FollowService.new.call(current_user.account, @account, reblogs: params.key?(:reblogs) ? truthy_param?(:reblogs) : nil, notify: params.key?(:notify) ? truthy_param?(:notify) : nil, languages: params.key?(:languages) ? params[:languages] : nil, with_rate_limit: true)
    options = @account.locked? || current_user.account.silenced? ? {} : { following_map: { @account.id => { reblogs: follow.show_reblogs?, notify: follow.notify?, languages: follow.languages } }, requested_map: { @account.id => false } }

    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships(**options)
  end

  def block
    BlockService.new.call(current_user.account, @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def mute
    MuteService.new.call(current_user.account, @account, notifications: truthy_param?(:notifications), duration: params[:duration].to_i)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def unfollow
    UnfollowService.new.call(current_user.account, @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships
  end

  def remove_from_followers
    RemoveFromFollowersService.new.call(current_user.account, @account)
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

  def set_accounts
    @accounts = Account.where(id: account_ids).without_unapproved
  end

  def check_account_approval
    raise(ActiveRecord::RecordNotFound) if @account.local? && @account.user_pending?
  end

  def check_account_confirmation
    raise(ActiveRecord::RecordNotFound) if @account.local? && !@account.user_confirmed?
  end

  def check_accounts_limit
    raise(Mastodon::ValidationError) if account_ids.size > DEFAULT_ACCOUNTS_LIMIT
  end

  def check_following_self
    render json: { error: I18n.t('accounts.self_follow_error') }, status: 403 if current_user.account.id == @account.id
  end

  def relationships(**)
    AccountRelationshipsPresenter.new([@account], current_user.account_id, **)
  end

  def account_ids
    Array(accounts_params[:id]).uniq.map(&:to_i)
  end

  def accounts_params
    params.permit(id: [])
  end

  def account_params
    params.permit(:username, :email, :password, :agreement, :locale, :reason, :time_zone, :invite_code, :date_of_birth)
  end

  def invite
    Invite.find_by(code: params[:invite_code]) if params[:invite_code].present?
  end

  def check_enabled_registrations
    forbidden unless allowed_registration?(request.remote_ip, invite)
  end
end
