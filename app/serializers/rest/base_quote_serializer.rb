# frozen_string_literal: true

class REST::BaseQuoteSerializer < ActiveModel::Serializer
  attributes :state

  def state
    return object.state unless object.accepted?

    # Extra states when a status is unavailable
    return 'deleted' if object.quoted_status.nil?

    status_filter.filter_state_for_quote || object.state
  end

  def quoted_status
    object.quoted_status if (object.accepted? || instance_options[:source_requested]) && object.quoted_status.present? && !object.quoted_status&.reblog? && status_filter.filter_state_for_quote != 'unauthorized'
  end

  private

  def status_filter
    @status_filter ||= begin
      if current_user && instance_options[:relationships]
        account_ids = instance_options[:relationships].authoring_accounts.pluck(:id)
        domains = instance_options[:relationships].authoring_accounts.pluck(:domain).uniq
        current_user.account.preload_relations!(account_ids, domains)
      end
      StatusFilter.new(object.quoted_status, current_user&.account)
    end
  end
end
