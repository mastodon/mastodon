# frozen_string_literal: true

module Admin::AccountsHelper
  def filter_params(more_params)
    params.permit(:local, :remote, :by_domain, :silenced, :suspended, :recent).merge(more_params)
  end

  def filter_link_to(text, more_params)
    link_to text, filter_params(more_params), class: filtered_link_class(more_params)
  end

  def table_link_to(icon, text, path, options = {})
    link_to safe_join([fa_icon(icon), text]), path, options.merge(class: 'table-action-link')
  end

  private

  def filtered_link_class(more_params)
    params.merge(more_params).compact == params.compact ? 'selected' : ''
  end
end
