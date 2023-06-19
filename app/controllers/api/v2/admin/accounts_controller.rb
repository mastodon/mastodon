# frozen_string_literal: true

class Api::V2::Admin::AccountsController < Api::V1::Admin::AccountsController
  FILTER_PARAMS = %i(
    origin
    status
    permissions
    username
    by_domain
    display_name
    email
    ip
    invited_by
  ).freeze

  PAGINATION_PARAMS = (%i(limit) + FILTER_PARAMS).freeze

  private

  def next_path
    api_v2_admin_accounts_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v2_admin_accounts_url(pagination_params(min_id: pagination_since_id)) unless @accounts.empty?
  end

  def filtered_accounts
    AccountFilter.new(filter_params).results
  end

  def filter_params
    params.permit(*FILTER_PARAMS)
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end
end
