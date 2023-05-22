# frozen_string_literal: true

class ActivityPub::Activity::Flag < ActivityPub::Activity
  def perform
    return if skip_reports?

    target_accounts            = object_uris.filter_map { |uri| account_from_uri(uri) }.select(&:local?)
    target_statuses_by_account = object_uris.filter_map { |uri| status_from_uri(uri) }.select(&:local?).group_by(&:account_id)

    target_accounts.each do |target_account|
      target_statuses = target_statuses_by_account[target_account.id]

      next if target_account.suspended?

      ReportService.new.call(
        @account,
        target_account,
        status_ids: target_statuses.nil? ? [] : target_statuses.map(&:id),
        category: report_category,
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
    @json['id'] unless @json['id'].nil? || non_matching_uri_hosts?(@account.uri, @json['id'])
  end

  def report_category
    summary = @json['summary']

    # If the summary is set to "violation", then we relabel as "other", as there will
    # be a mismatch between Reporting Instance's Rules and the Local Instance's
    # Rules causing the Report validation to fail.
    return 'other' if summary == 'violation'

    # Otherwise, return the summary as the category if it is in the list of
    # available Report categories, otherwise default to "other"
    Report.categories.include?(summary) ? summary : 'other'
  end
end
