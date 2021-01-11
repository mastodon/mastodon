# frozen_string_literal: true

class ActivityPub::Activity::Flag < ActivityPub::Activity
  def perform
    return if skip_reports?

    target_accounts            = object_uris.filter_map { |uri| account_from_uri(uri) }.select(&:local?)
    target_statuses_by_account = object_uris.filter_map { |uri| status_from_uri(uri) }.select(&:local?).group_by(&:account_id)

    target_accounts.each do |target_account|
      target_statuses = target_statuses_by_account[target_account.id]

      ReportService.new.call(
        @account,
        target_account,
        status_ids: target_statuses.nil? ? [] : target_statuses.map(&:id),
        comment: @json['content'] || '',
        uri: report_uri
      )
    end
  end

  private

  def skip_reports?
    DomainBlock.reject_reports?(@account.domain)
  end

  def object_uris
    @object_uris ||= Array(@object.is_a?(Array) ? @object.map { |item| value_or_id(item) } : value_or_id(@object))
  end

  def report_uri
    @json['id'] unless @json['id'].nil? || invalid_origin?(@json['id'])
  end
end
