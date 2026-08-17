# frozen_string_literal: true

class REST::AnnualReportSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :year, :data, :schema_version, :share_url, :account_id

  def share_url
    public_wrapstodon_url(object.account, object.year, object.share_key) if object.share_key.present?
  end

  def account_id
    object.account_id.to_s
  end
end
