# frozen_string_literal: true

class Api::V1::Instances::DomainBlocksController < Api::BaseController
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  before_action :require_enabled_api!
  before_action :set_domain_blocks

  vary_by '', if: -> { Setting.show_domain_blocks == 'all' }

  def index
    if Setting.show_domain_blocks == 'all'
      cache_even_if_authenticated!
    else
      cache_if_unauthenticated!
    end

    render json: @domain_blocks, each_serializer: REST::DomainBlockSerializer, with_comment: (Setting.show_domain_blocks_rationale == 'all' || (Setting.show_domain_blocks_rationale == 'users' && user_signed_in?))
  end

  private

  def require_enabled_api!
    head 404 unless Setting.show_domain_blocks == 'all' || (Setting.show_domain_blocks == 'users' && user_signed_in?)
  end

  def set_domain_blocks
    @domain_blocks = DomainBlock.with_user_facing_limitations.by_severity
  end
end
