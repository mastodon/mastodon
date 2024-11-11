# frozen_string_literal: true

class ForwardReportService < BaseService
  include Payloadable

  def call(report)
    @report = report

    forward_to_origin!
    update_report!
  end

  private

  def forward_to_origin!
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, @report.target_account.inbox_url)
  end

  def update_report!
    @report.update(forwarded: true)
  end

  def payload
    Oj.dump(serialize_payload(@report, ActivityPub::FlagSerializer, account: some_local_account))
  end

  def some_local_account
    @some_local_account ||= Account.representative
  end
end
