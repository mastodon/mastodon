# frozen_string_literal: true

module WrapstodonHelper
  def render_wrapstodon_share_data(report)
    json = ActiveModelSerializers::SerializableResource.new(
      AnnualReportsPresenter.new([report]),
      serializer: REST::AnnualReportsSerializer,
      scope: nil,
      scope_name: :current_user
    ).to_json

    # rubocop:disable Rails/OutputSafety
    content_tag(:script, json_escape(json).html_safe, type: 'application/json', id: 'wrapstodon-data')
    # rubocop:enable Rails/OutputSafety
  end
end
