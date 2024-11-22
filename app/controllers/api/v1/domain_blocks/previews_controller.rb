# frozen_string_literal: true

class Api::V1::DomainBlocks::PreviewsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:blocks' }
  before_action :require_user!
  before_action :set_domain
  before_action :set_domain_block_preview

  def show
    render json: @domain_block_preview, serializer: REST::DomainBlockPreviewSerializer
  end

  private

  def set_domain
    @domain = TagManager.instance.normalize_domain(params[:domain])
  end

  def set_domain_block_preview
    @domain_block_preview = with_read_replica do
      DomainBlockPreviewPresenter.new(
        following_count: current_account.following.where(domain: @domain).count,
        followers_count: current_account.followers.where(domain: @domain).count
      )
    end
  end
end
