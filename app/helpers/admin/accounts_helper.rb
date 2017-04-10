# frozen_string_literal: true

module Admin::AccountsHelper
  def filter_params(more_params)
    params.permit(:local, :remote, :by_domain, :by_username, :silenced, :suspended, :recent).merge(more_params)
  end

  def filter_link_to(text, more_params)
    link_to text, filter_params(more_params), class: params.merge(more_params).compact == params.compact ? 'selected' : ''
  end

  def filter_form(name)
    form_tag('', method: 'get', class: 'simple_form') do
      form_content = text_field_tag(name, params[name], placeholder: t('placeholder.search'))
      filter_params({}).each do |key, value|
        next if key == name
        form_content += hidden_field_tag(key, value)
      end
      form_content
    end
  end

  def table_link_to(icon, text, path, options = {})
    link_to safe_join([fa_icon(icon), text]), path, options.merge(class: 'table-action-link')
  end
end
