# frozen_string_literal: true

class Api::V1::Instances::DomainBlocksController < Api::V1::Instances::BaseController
  before_action :require_enabled_api!
  before_action :set_domain_blocks

  vary_by '', if: -> { Setting.show_domain_blocks == 'all' }

  def index
    if Setting.show_domain_blocks == 'all'
      cache_even_if_authenticated!
    else
      cache_if_unauthenticated!
    end

    render json: @domain_blocks, each_serializer: REST::DomainBlockSerializer, with_comment: show_rationale_in_response?
  end

  private

  def require_enabled_api!
    head 404 unless api_enabled?
  end

  def api_enabled?
    show_domain_blocks_for_all? || show_domain_blocks_to_user?
  end

  def show_domain_blocks_for_all?
    Setting.show_domain_blocks == 'all'
  end

  def show_domain_blocks_to_user?
    Setting.show_domain_blocks == 'users' && user_signed_in? && current_user.functional_or_moved?
  end

  def set_domain_blocks
    @domain_blocks = DomainBlock.with_user_facing_limitations.by_severity
  end

  def show_rationale_in_response?
    always_show_rationale? || show_rationale_for_user?
  end

  def always_show_rationale?
    Setting.show_domain_blocks_rationale == 'all'
  end

  def show_rationale_for_user?
    Setting.show_domain_blocks_rationale == 'users' && user_signed_in? && current_user.functional_or_moved?
  end
end
