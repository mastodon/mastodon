# frozen_string_literal: true

module Admin::FilterHelper
  FILTERS = [
    AccountFilter::KEYS,
    CustomEmojiFilter::KEYS,
    ReportFilter::KEYS,
    TagFilter::KEYS,
    InstanceFilter::KEYS,
    InviteFilter::KEYS,
    RelationshipFilter::KEYS,
    AnnouncementFilter::KEYS,
  ].flatten.freeze

  def filter_link_to(text, link_to_params, link_class_params = link_to_params)
    new_url   = filtered_url_for(link_to_params)
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
