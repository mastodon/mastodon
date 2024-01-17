# frozen_string_literal: true

class Api::V1::Peers::SearchController < Api::BaseController
  before_action :require_enabled_api!
  before_action :set_domains

  skip_before_action :require_authenticated_user!, unless: :limited_federation_mode?
  skip_around_action :set_locale

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

    @domains = domains_matching_search_param.limit(10).pluck(:domain)
  end

  def domains_matching_search_param
    if Chewy.enabled?
      search_index_query_domains
    else
      database_query_domains
    end
  rescue Addressable::URI::InvalidURIError
    []
  end

  def search_index_query_domains
    InstancesIndex.query(function_score: {
      query: {
        prefix: {
          domain: normalized_domain,
        },
      },

      field_value_factor: {
        field: 'accounts_count',
        modifier: 'log2p',
      },
    })
  end

  def database_query_domains
    Instance.searchable.domain_starts_with(normalized_domain)
  end

  def normalized_domain
    TagManager.instance.normalize_domain(query_value)
  end

  def query_value
    params[:q].strip
  end
end
