# frozen_string_literal: true

class REST::ShallowQuoteSerializer < ActiveModel::Serializer
  attributes :state, :quoted_status_id

  def quoted_status_id
    return unless object.accepted?

    quoted_status = object.quoted_status
    return if quoted_status.nil?

    status_filter = StatusFilter.new(quoted_status, current_user&.account, instance_options[:relationships] || {})
    quoted_status.id.to_s unless status_filter.filtered?
  end
end
