# frozen_string_literal: true

class ReportService < BaseService
  include Payloadable

  def call(source_account, target_account, options = {})
    @source_account = source_account
    @target_account = target_account
    @status_ids     = options.delete(:status_ids).presence || []
    @comment        = options.delete(:comment).presence || ''
    @category       = options.delete(:category).presence || 'other'
    @rule_ids       = options.delete(:rule_ids).presence
    @options        = options

    raise ActiveRecord::RecordNotFound if @target_account.suspended?

    create_report!
    notify_staff!
    forward_to_origin! if forward?

    @report
  end

  private

  def create_report!
    @report = @source_account.reports.create!(
      target_account: @target_account,
      status_ids: reported_status_ids,
      comment: @comment,
      uri: @options[:uri],
      forwarded: forward?,
      category: @category,
      rule_ids: @rule_ids
    )
  end

  def notify_staff!
    return if @report.unresolved_siblings?

    User.those_who_can(:manage_reports).includes(:account).each do |u|
      LocalNotificationWorker.perform_async(u.account_id, @report.id, 'Report', 'admin.report')
      AdminMailer.new_report(u.account, @report).deliver_later if u.allows_report_emails?
    end
  end

  def forward_to_origin!
    ActivityPub::DeliveryWorker.perform_async(
      payload,
      some_local_account.id,
      @target_account.inbox_url
    )
  end

  def forward?
    !@target_account.local? && ActiveModel::Type::Boolean.new.cast(@options[:forward])
  end

  def reported_status_ids
    return AccountStatusesFilter.new(@target_account, @source_account).results.with_discarded.find(Array(@status_ids)).pluck(:id) if @source_account.local?

    # If the account making reports is remote, it is likely anonymized so we have to relax the requirements for attaching statuses.
    domain = @source_account.domain.to_s.downcase
    has_followers = @target_account.followers.where(Account.arel_table[:domain].lower.eq(domain)).exists?
    visibility = has_followers ? %i(public unlisted private) : %i(public unlisted)
    scope = @target_account.statuses.with_discarded
    scope.merge!(scope.where(visibility: visibility).or(scope.where('EXISTS (SELECT 1 FROM mentions m JOIN accounts a ON m.account_id = a.id WHERE lower(a.domain) = ?)', domain)))
    # Allow missing posts to not drop reports that include e.g. a deleted post
    scope.where(id: Array(@status_ids)).pluck(:id)
  end

  def payload
    Oj.dump(serialize_payload(@report, ActivityPub::FlagSerializer, account: some_local_account))
  end

  def some_local_account
    @some_local_account ||= Account.representative
  end
end
