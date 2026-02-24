# frozen_string_literal: true

class Admin::BaseAction
  include ActiveModel::Model
  include ActiveModel::Attributes
  include AccountableConcern
  include Authorization

  attr_accessor :current_account,
                :type,
                :text,
                :report_id

  attr_reader :warning

  attribute :send_email_notification, :boolean, default: true

  alias send_email_notification? send_email_notification

  validates :type, :current_account, presence: true
  validates :type, inclusion: { in: ->(a) { a.class::TYPES } }

  def save
    return false unless valid?

    process_action!

    true
  end

  def save!
    raise ActiveRecord::RecordInvalid, self unless save
  end

  def report
    @report ||= Report.find(report_id) if report_id.present?
  end

  def with_report?
    !report.nil?
  end
end
