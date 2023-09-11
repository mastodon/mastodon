# frozen_string_literal: true

class Api::V1::NoticesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: :destroy
  before_action :require_user!
  before_action :set_notices, only: :index
  before_action :set_notice, except: :index

  def index
    render json: @notices, each_serializer: REST::NoticeSerializer
  end

  def destroy
    @notice.dismiss_for_user!(current_user)
    render_empty
  end

  private

  def set_notices
    @notices = [Notice.first_unseen(current_user)].compact
  end

  def set_notice
    @notice = Notice.find(params[:id])
  end
end
