# frozen_string_literal: true

class Api::V2::InstanceStatsController < Api::BaseController
  def show
    expires_in 3.minutes, public: true
    render_with_cache json: InstanceStatsPresenter.new(params[:domain]), serializer: REST::InstanceStatsSerializer, key: params[:domain], root: 'instance-stats'
  end
end
