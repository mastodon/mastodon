# frozen_string_literal: true

module Admin::FilterHelper
  ACCOUNT_FILTERS      = %i(local remote by_domain silenced suspended alphabetic username display_name email ip staff).freeze
  REPORT_FILTERS       = %i(resolved account_id target_account_id).freeze
  INVITE_FILTER        = %i(available expired).freeze
  CUSTOM_EMOJI_FILTERS = %i(local remote by_domain shortcode).freeze

  FILTERS = ACCOUNT_FILTERS + REPORT_FILTERS + INVITE_FILTER + CUSTOM_EMOJI_FILTERS

  def filter_link_to(text, link_to_params, link_class_params = link_to_params)
    new_url = filtered_url_for(link_to_params)
    new_class = filtered_url_for(link_class_params)
    link_to text, new_url, class: filter_link_class(new_class)
  end

  def table_link_to(icon, text, path, **options)
    link_to safe_join([fa_icon(icon), text]), path, options.merge(class: 'table-action-link')
  end

  def selected?(more_params)
    new_url = filtered_url_for(more_params)
    filter_link_class(new_url) == 'selected'
  end

  private

  def filter_params(more_params)
    controller_request_params.merge(more_params)
  end

  def filter_link_class(new_url)
    filtered_url_for(controller_request_params) == new_url ? 'selected' : ''
  end

  def filtered_url_for(url_params)
    url_for filter_params(url_params)
  end

  def controller_request_params
    params.permit(FILTERS)
  end
end
