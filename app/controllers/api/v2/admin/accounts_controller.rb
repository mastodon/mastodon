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
    role_ids
  ).freeze

  PAGINATION_PARAMS = (%i(limit) + FILTER_PARAMS).freeze

  private

  def filtered_accounts
    AccountFilter.new(translated_filter_params).results
  end

  def translated_filter_params
    translated_params = filter_params.slice(*AccountFilter::KEYS)

    translated_params[:role_ids] = UserRole.that_can(:manage_reports).map(&:id) if params[:permissions] == 'staff'

    translated_params
  end

  def filter_params
    params.permit(*FILTER_PARAMS, role_ids: [])
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end
end
