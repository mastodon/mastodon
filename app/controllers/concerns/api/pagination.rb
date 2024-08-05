# frozen_string_literal: true

module Api::Pagination
  extend ActiveSupport::Concern

  PAGINATION_PARAMS = %i(limit).freeze

  protected

  def pagination_max_id
    pagination_collection.last.id
  end

  def pagination_since_id
    pagination_collection.first.id
  end

  def set_pagination_headers(next_path = nil, prev_path = nil)
    links = []
    links << [next_path, [%w(rel next)]] if next_path
    links << [prev_path, [%w(rel prev)]] if prev_path
    response.headers['Link'] = LinkHeader.new(links) unless links.empty?
  end

  def require_valid_pagination_options!
    render json: { error: 'Pagination values for `offset` and `limit` must be positive' }, status: 400 if pagination_options_invalid?
  end

  def pagination_params(core_params)
    params
      .slice(*PAGINATION_PARAMS)
      .permit(*PAGINATION_PARAMS)
      .merge(core_params)
  end

  private

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_options_invalid?
    params.slice(:limit, :offset).values.map(&:to_i).any?(&:negative?)
  end
end
