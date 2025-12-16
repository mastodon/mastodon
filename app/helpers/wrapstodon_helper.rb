# frozen_string_literal: true

module WrapstodonHelper
  def render_wrapstodon_share_data(report)
    payload = ActiveModelSerializers::SerializableResource.new(
      AnnualReportsPresenter.new([report]),
      serializer: REST::AnnualReportsSerializer,
      scope: nil,
      scope_name: :current_user
    ).as_json

    payload[:me] = current_account.id.to_s if user_signed_in?
    payload[:domain] = Addressable::IDNA.to_unicode(Rails.configuration.x.local_domain)

    json_string = payload.to_json

    # rubocop:disable Rails/OutputSafety
    content_tag(:script, json_escape(json_string).html_safe, type: 'application/json', id: 'wrapstodon-data')
    # rubocop:enable Rails/OutputSafety
  end
end
