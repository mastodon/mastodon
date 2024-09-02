# frozen_string_literal: true

class ReportForwardingService < BaseService
  include Payloadable

  def call(report, options = {})
    @report = report
    @options = options

    return unless @report.forwardable?

    unless forward_to_domains.empty?
      forward_to_origin! if forward_to_origin?
      forward_to_replied_to!
    end
  end

  def forward_to_origin!
    # Send report to the server where the account originates from
    ActivityPub::DeliveryWorker.perform_async(payload, instance_representative.id, @report.target_account.inbox_url)
  end

  def forward_to_replied_to!
    # Send report to servers to which the account was replying to, so they also have a chance to act
    inbox_urls = Account.remote.where(domain: forward_to_domains).where(id: Status.where(id: @report.status_ids).where.not(in_reply_to_account_id: nil).select(:in_reply_to_account_id)).inboxes - [@report.target_account.inbox_url, @report.target_account.shared_inbox_url]

    inbox_urls.each do |inbox_url|
      ActivityPub::DeliveryWorker.perform_async(payload, instance_representative.id, inbox_url)
    end
  end

  def forward_to_origin?
    forward_to_domains.include?(@report.target_account.domain)
  end

  def forward_to_domains
    @forward_to_domains ||= @options[:forward_to_domains].filter_map { |domain| TagManager.instance.normalize_domain(domain&.strip) }.uniq
  end

  def payload
    Oj.dump(serialize_payload(@report, ActivityPub::FlagSerializer, account: instance_representative))
  end

  def instance_representative
    @instance_representative ||= Account.representative
  end
end
