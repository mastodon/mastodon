# frozen_string_literal: true
# == Schema Information
#
# Table name: reports
#
#  id                         :bigint(8)        not null, primary key
#  status_ids                 :bigint(8)        default([]), not null, is an Array
#  comment                    :text             default(""), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  account_id                 :bigint(8)        not null
#  action_taken_by_account_id :bigint(8)
#  target_account_id          :bigint(8)        not null
#  assigned_account_id        :bigint(8)
#  uri                        :string
#  forwarded                  :boolean
#  category                   :integer          default("other"), not null
#  action_taken_at            :datetime
#  rule_ids                   :bigint(8)        is an Array
#

class Report < ApplicationRecord
  self.ignored_columns = %w(action_taken)

  include Paginable
  include RateLimitable

  rate_limit by: :account, family: :reports

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'
  belongs_to :action_taken_by_account, class_name: 'Account', optional: true
  belongs_to :assigned_account, class_name: 'Account', optional: true

  has_many :notes, class_name: 'ReportNote', foreign_key: :report_id, inverse_of: :report, dependent: :destroy

  scope :unresolved, -> { where(action_taken_at: nil) }
  scope :resolved,   -> { where.not(action_taken_at: nil) }
  scope :with_accounts, -> { includes([:account, :target_account, :action_taken_by_account, :assigned_account].index_with({ user: [:invite_request, :invite] })) }

  validates :comment, length: { maximum: 1_000 }
  validates :rule_ids, absence: true, unless: :violation?

  validate :validate_rule_ids

  enum category: {
    other: 0,
    spam: 1_000,
    violation: 2_000,
  }

  def local?
    false # Force uri_for to use uri attribute
  end

  before_validation :set_uri, only: :create

  def object_type
    :flag
  end

  def statuses
    Status.with_discarded.where(id: status_ids)
  end

  def media_attachments_count
    statuses_to_query = []
    count = 0

    statuses.pluck(:id, :ordered_media_attachment_ids).each do |id, ordered_ids|
      if ordered_ids.nil?
        statuses_to_query << id
      else
        count += ordered_ids.size
      end
    end

    count += MediaAttachment.where(status_id: statuses_to_query).count unless statuses_to_query.empty?
    count
  end

  def rules
    Rule.with_discarded.where(id: rule_ids)
  end

  def assign_to_self!(current_account)
    update!(assigned_account_id: current_account.id)
  end

  def unassign!
    update!(assigned_account_id: nil)
  end

  def resolve!(acting_account)
    update!(action_taken_at: Time.now.utc, action_taken_by_account_id: acting_account.id)
  end

  def unresolve!
    update!(action_taken_at: nil, action_taken_by_account_id: nil)
  end

  def action_taken?
    action_taken_at.present?
  end

  alias action_taken action_taken?

  def unresolved?
    !action_taken?
  end

  def unresolved_siblings?
    Report.where.not(id: id).where(target_account_id: target_account_id).unresolved.exists?
  end

  def history
    subquery = [
      Admin::ActionLog.where(
        target_type: 'Report',
        target_id: id
      ).unscope(:order).arel,

      Admin::ActionLog.where(
        target_type: 'Account',
        target_id: target_account_id
      ).unscope(:order).arel,

      Admin::ActionLog.where(
        target_type: 'Status',
        target_id: status_ids
      ).unscope(:order).arel,
    ].reduce { |union, query| Arel::Nodes::UnionAll.new(union, query) }

    Admin::ActionLog.from(Arel::Nodes::As.new(subquery, Admin::ActionLog.arel_table))
  end

  def set_uri
    self.uri = ActivityPub::TagManager.instance.generate_uri_for(self) if uri.nil? && account.local?
  end

  def validate_rule_ids
    return unless violation?

    errors.add(:rule_ids, I18n.t('reports.errors.invalid_rules')) unless rules.size == rule_ids&.size
  end
end
