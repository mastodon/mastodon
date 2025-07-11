# frozen_string_literal: true

class ActivityPub::Activity::Reject < ActivityPub::Activity
  def perform
    return reject_follow_for_relay if relay_follow?
    return follow_request_from_object.reject! unless follow_request_from_object.nil?
    return UnfollowService.new.call(follow_from_object.account, @account) unless follow_from_object.nil?
    return reject_quote!(quote_request_from_object) unless quote_request_from_object.nil?

    case @object['type']
    when 'Follow'
      reject_embedded_follow
    when 'QuoteRequest'
      reject_embedded_quote
    end
  end

  private

  def reject_embedded_follow
    target_account = account_from_uri(target_uri)

    return if target_account.nil? || !target_account.local?

    follow_request = FollowRequest.find_by(account: target_account, target_account: @account)
    follow_request&.reject!

    UnfollowService.new.call(target_account, @account) if target_account.following?(@account)
  end

  def reject_follow_for_relay
    relay.update!(state: :rejected)
  end

  def reject_embedded_quote
    quoted_status_uri = value_or_id(@object['object'])
    quoting_status_uri = value_or_id(@object['instrument'])
    approval_uri = value_or_id(@json['instrument'])
    return if quoted_status_uri.nil? || quoted_uri.nil? || approval_uri.nil?

    quoting_status = status_from_uri(quoting_status_uri)
    return unless quoting_status.local?

    quoted_status = status_from_uri(quoted_status_uri)
    return unless quoted_status.account == @account && quoting_status.quote.quoted_status == quoted_status

    reject_quote!(quoting_status.quote)
  end

  def reject_quote!(quote)
    return unless quote.quoted_account == @account && quote.status.local?

    # TODO: broadcast an update?
    quote.reject!
  end

  def relay
    @relay ||= Relay.find_by(follow_activity_id: object_uri) unless object_uri.nil?
  end

  def relay_follow?
    relay.present?
  end

  def target_uri
    @target_uri ||= value_or_id(@object['actor'])
  end
end
