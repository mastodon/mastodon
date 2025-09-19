# frozen_string_literal: true

class REST::BaseQuoteSerializer < ActiveModel::Serializer
  attributes :state

  def state
    return object.state unless object.accepted?

    # Extra states when a status is unavailable
    return 'deleted' if object.quoted_status.nil?
    return 'unauthorized' if status_filter.filtered_for_quote?

    object.state
  end

  def quoted_status
    object.quoted_status if object.accepted? && object.quoted_status.present? && !status_filter.filtered_for_quote?
  end

  private

  def status_filter
    @status_filter ||= StatusFilter.new(object.quoted_status, current_user&.account, instance_options[:relationships]&.preloaded_account_relations || {})
  end
end
