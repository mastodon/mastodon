# frozen_string_literal: true

class ApiController < ApplicationController
  DEFAULT_STATUSES_LIMIT = 20
  DEFAULT_ACCOUNTS_LIMIT = 40

  protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token

  before_action :set_rate_limit_headers

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.to_s }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Record not found' }, status: 404
  end

  rescue_from Goldfinger::Error do
    render json: { error: 'Remote account could not be resolved' }, status: 422
  end

  rescue_from HTTP::Error do
    render json: { error: 'Remote data could not be fetched' }, status: 503
  end

  rescue_from OpenSSL::SSL::SSLError do
    render json: { error: 'Remote SSL certificate could not be verified' }, status: 503
  end

  def doorkeeper_unauthorized_render_options(*)
    { json: { error: 'Not authorized' } }
  end

  def doorkeeper_forbidden_render_options(*)
    { json: { error: 'This action is outside the authorized scopes' } }
  end

  protected

  def set_rate_limit_headers
    return if request.env['rack.attack.throttle_data'].nil?

    now        = Time.now.utc
    match_data = request.env['rack.attack.throttle_data']['api']

    response.headers['X-RateLimit-Limit']     = match_data[:limit].to_s
    response.headers['X-RateLimit-Remaining'] = (match_data[:limit] - match_data[:count]).to_s
    response.headers['X-RateLimit-Reset']     = (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
  end

  def set_pagination_headers(next_path = nil, prev_path = nil)
    links = []
    links << [next_path, [%w(rel next)]] if next_path
    links << [prev_path, [%w(rel prev)]] if prev_path
    response.headers['Link'] = LinkHeader.new(links)
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
    super || current_resource_owner
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def require_user!
    current_resource_owner
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'This method requires an authenticated user' }, status: 422
  end

  def render_empty
    render json: {}, status: 200
  end

  def set_maps(statuses) # rubocop:disable Style/AccessorMethodName
    if current_account.nil?
      @reblogs_map    = {}
      @favourites_map = {}
      return
    end

    status_ids      = statuses.flat_map { |s| [s.id, s.reblog_of_id] }.compact.uniq
    @reblogs_map    = Status.reblogs_map(status_ids, current_account)
    @favourites_map = Status.favourites_map(status_ids, current_account)
  end

  def set_counters_maps(statuses) # rubocop:disable Style/AccessorMethodName
    status_ids             = statuses.map { |s| s.reblog? ? s.reblog_of_id : s.id }.uniq
    @favourites_counts_map = Favourite.select('status_id, COUNT(id) AS favourites_count').group('status_id').where(status_id: status_ids).map { |f| [f.status_id, f.favourites_count] }.to_h
    @reblogs_counts_map    = Status.select('statuses.id, COUNT(reblogs.id) AS reblogs_count').joins('LEFT OUTER JOIN statuses AS reblogs ON statuses.id = reblogs.reblog_of_id').where(id: status_ids).group('statuses.id').map { |r| [r.id, r.reblogs_count] }.to_h
  end

  def set_account_counters_maps(accounts) # rubocop:disable Style/AccessorMethodName
    account_ids = accounts.map(&:id)
    @followers_counts_map = Follow.unscoped.select('target_account_id, COUNT(account_id) AS followers_count').group('target_account_id').where(target_account_id: account_ids).map { |f| [f.target_account_id, f.followers_count] }.to_h
    @following_counts_map = Follow.unscoped.select('account_id, COUNT(target_account_id) AS following_count').group('account_id').where(account_id: account_ids).map { |f| [f.account_id, f.following_count] }.to_h
    @statuses_counts_map  = Status.unscoped.select('account_id, COUNT(id) AS statuses_count').group('account_id').where(account_id: account_ids).map { |s| [s.account_id, s.statuses_count] }.to_h
  end
end
