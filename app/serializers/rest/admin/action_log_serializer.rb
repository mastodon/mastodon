# frozen_string_literal: true

# Action logs are obnoxiously polymorphic: only one of the typed target properties will exist per log.
# Not all targets have admin API serializations, so we use non-admin API serializations for those.
# Some targets like account warnings don't have a convenient API representation,
# so we serialize a related object like the account instead.
# Some targets have no API serializations and no related objects,
# and we don't serialize those, but we still send a `target_type` and `target_id`.
#
# Some target types are renamed to match the docs, and all are lower_snake_cased,
# much like `Notification.activity_type`.
#
# Clients that want to display this output should look at the web UI's `ActionLogsHelper` for inspiration.
class REST::Admin::ActionLogSerializer < ActiveModel::Serializer
  attributes :id,
             :action,
             :target_type,
             :target_id,
             :created_at,
             :updated_at,
             :human_identifier,
             :link

  # All action logs have these properties.

  def id
    object.id.to_s
  end

  # Keep this in sync with `ActionLogFilter.scope_for`.
  def target_type
    case object.target_type
    when 'UserRole'
      'role'
    else
      object.target_type.underscore
    end
  end

  def target_id
    object.target_id&.to_s
  end

  def created_at
    object.created_at.iso8601
  end

  def updated_at
    object.updated_at.iso8601
  end

  # Permalink or admin web UI link relevant to target object, if it has one. May be nil.
  def link
    case object.target_type
    when 'Account'
      admin_account_path(object.target_id)
    when 'User'
      admin_account_path(object.route_param) if object.route_param.present?
    when 'UserRole'
      admin_roles_path(object.target_id)
    when 'Report'
      admin_report_path(object.target_id)
    when 'DomainBlock', 'DomainAllow', 'EmailDomainBlock', 'UnavailableDomain'
      "https://#{object.human_identifier}" if object.human_identifier.present?
    when 'Status'
      object.permalink
    when 'AccountWarning'
      disputes_strike_path(object.target_id)
    when 'Announcement'
      edit_admin_announcement_path(object.target_id)
    when 'Appeal'
      disputes_strike_path(object.route_param) if object.route_param.present?
    end
  end

  belongs_to :subject, serializer: REST::Admin::AccountSerializer

  # Note that the action log model's `account` column is serialized as `subject`
  # so that the target account can be serialized as simply `account` and not `target_account`.
  def subject
    object.account
  end

  # These targets serialize as admin API types.

  belongs_to :account, if: :any_account_target?, serializer: REST::Admin::AccountSerializer

  def account
    if account_target?
      object.target
    elsif user_target?
      object.target.account
    elsif account_warning_target?
      object.target.target_account
    end
  end

  def any_account_target?
    account_target? || user_target? || account_warning_target?
  end

  def account_target?
    object.target_type == 'Account'
  end

  def user_target?
    object.target_type == 'User'
  end

  def account_warning_target?
    object.target_type == 'AccountWarning'
  end

  belongs_to :canonical_email_block, if: :canonical_email_block_target?, serializer: REST::Admin::CanonicalEmailBlockSerializer

  def canonical_email_block
    object.target if canonical_email_block_target?
  end

  def canonical_email_block_target?
    object.target_type == 'CanonicalEmailBlock'
  end

  belongs_to :domain_allow, if: :domain_allow_target?, serializer: REST::Admin::DomainAllowSerializer

  def domain_allow
    object.target if domain_allow_target?
  end

  def domain_allow_target?
    object.target_type == 'DomainAllow'
  end

  belongs_to :domain_block, if: :domain_block_target?, serializer: REST::Admin::DomainBlockSerializer

  def domain_block
    object.target if domain_block_target?
  end

  def domain_block_target?
    object.target_type == 'DomainBlock'
  end

  belongs_to :email_domain_block, if: :email_domain_block_target?, serializer: REST::Admin::EmailDomainBlockSerializer

  def email_domain_block
    object.target if email_domain_block_target?
  end

  def email_domain_block_target?
    object.target_type == 'EmailDomainBlock'
  end

  belongs_to :ip_block, if: :ip_block_target?, serializer: REST::Admin::IpBlockSerializer

  def ip_block
    object.target if ip_block_target?
  end

  def ip_block_target?
    object.target_type == 'IpBlock'
  end

  belongs_to :report, if: :report_target?, serializer: REST::Admin::ReportSerializer

  def report
    object.target if report_target?
  end

  def report_target?
    object.target_type == 'Report'
  end

  # These targets serialize as non-admin API types.

  belongs_to :announcement, if: :announcement_target?, serializer: REST::AnnouncementSerializer

  def announcement
    object.target if announcement_target?
  end

  def announcement_target?
    object.target_type == 'Announcement'
  end

  belongs_to :custom_emoji, if: :custom_emoji_target?, serializer: REST::CustomEmojiSerializer

  def custom_emoji
    object.target if custom_emoji_target?
  end

  def custom_emoji_target?
    object.target_type == 'CustomEmoji'
  end

  belongs_to :role, if: :role_target?, serializer: REST::RoleSerializer

  def role
    object.target if role_target?
  end

  def role_target?
    object.target_type == 'UserRole'
  end

  belongs_to :status, if: :status_target?, serializer: REST::StatusSerializer

  def status
    object.target if status_target?
  end

  def status_target?
    object.target_type == 'Status'
  end
end
