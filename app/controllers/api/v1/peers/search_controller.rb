# frozen_string_literal: true

class Api::V1::Peers::SearchController < Api::BaseController
  before_action :require_enabled_api!
  before_action :set_domains

  skip_before_action :require_authenticated_user!, unless: :limited_federation_mode?
  skip_around_action :set_locale

  LIMIT = 10

  vary_by ''

  def index
    cache_even_if_authenticated!
    render json: @domains
  end

  private

  def require_enabled_api!
    head 404 unless Setting.peers_api_enabled && !limited_federation_mode?
  end

  def set_domains
    return if params[:q].blank?

    if Chewy.enabled?
      @domains = InstancesIndex.query(function_score: {
        query: {
          prefix: {
            domain: normalized_domain,
          },
        },

        field_value_factor: {
          field: 'accounts_count',
          modifier: 'log2p',
        },
      }).limit(LIMIT).pluck(:domain)
    else
      domain = normalized_domain
      @domains = Instance.searchable.domain_starts_with(domain).limit(LIMIT).pluck(:domain)
    end
  rescue Addressable::URI::InvalidURIError
    @domains = []
  end

  def normalized_domain
    TagManager.instance.normalize_domain(query_value)
  end

  def query_value
    params[:q].strip
  end
end
