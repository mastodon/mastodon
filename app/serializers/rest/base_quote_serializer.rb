# frozen_string_literal: true

class REST::BaseQuoteSerializer < ActiveModel::Serializer
  attributes :state

  def quoted_status
    return unless object.accepted?

    quoted_status = object.quoted_status
    return if quoted_status.nil?

    status_filter = StatusFilter.new(quoted_status, current_user&.account, instance_options[:relationships] || {})
    quoted_status unless status_filter.filtered?
  end
end
