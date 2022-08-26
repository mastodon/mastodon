# frozen_string_literal: true

class Api::V1::GroupsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:groups' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:groups' }, except: [:index, :show]

  before_action :require_user!, except: [:show]
  before_action :set_group, except: [:index, :create]

  def index
    @groups = Group.joins(:members).where(members: { id: current_account.id })
    render json: @groups, each_serializer: REST::GroupSerializer
  end

  def show
    render json: @group, serializer: REST::GroupSerializer
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end
end
