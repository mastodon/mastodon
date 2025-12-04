# frozen_string_literal: true

class REST::AnnualReportSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :year, :data, :schema_version, :share_url

  def share_url
    public_wrapstodon_url(object.account, object.year, object.share_key) if object.share_key.present?
  end
end
