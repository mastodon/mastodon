# frozen_string_literal: true

module WrapstodonHelper
  def render_wrapstodon_share_data(report)
    ActiveModelSerializers::SerializableResource.new(
      AnnualReportsPresenter.new([report]),
      serializer: REST::AnnualReportsSerializer,
      scope: nil,
      scope_name: :current_user
    ).to_json
  end
end
