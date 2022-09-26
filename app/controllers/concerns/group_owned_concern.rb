# frozen_string_literal: true

module GroupOwnedConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, if: -> { whitelist_mode? && request.format != :json }
    before_action :set_group
    before_action :check_group_suspension
  end

  private

  def set_group
    @group = Group.local.find(group_id_param)
  end

  def group_id_param
    params[:group_id]
  end

  def check_group_suspension
    if @group.suspended_permanently?
      permanent_suspension_response
    elsif @group.suspended? && !skip_temporary_suspension_response?
      temporary_suspension_response
    end
  end

  def skip_temporary_suspension_response?
    false
  end

  def permanent_suspension_response
    expires_in(3.minutes, public: true)
    gone
  end

  def temporary_suspension_response
    expires_in(3.minutes, public: true)
    forbidden
  end
end
