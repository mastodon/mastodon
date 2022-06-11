# frozen_string_literal: true

# == Schema Information
#
# Table name: user_roles
#
#  id          :bigint(8)        not null, primary key
#  name        :string           default(""), not null
#  color       :string           default(""), not null
#  position    :integer          default(0), not null
#  permissions :bigint(8)        default(0), not null
#  highlighted :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserRole < ApplicationRecord
  FLAGS = {
    administrator: (1 << 0),
    view_devops: (1 << 1),
    view_audit_log: (1 << 2),
    view_dashboard: (1 << 3),
    manage_reports: (1 << 4),
    manage_federation: (1 << 5),
    manage_settings: (1 << 6),
    manage_blocks: (1 << 7),
    manage_taxonomies: (1 << 8),
    manage_appeals: (1 << 9),
    manage_users: (1 << 10),
    manage_invites: (1 << 11),
    manage_rules: (1 << 12),
    manage_announcements: (1 << 13),
    manage_custom_emojis: (1 << 14),
    manage_webhooks: (1 << 15),
    invite_users: (1 << 16),
    manage_roles: (1 << 17),
  }.freeze

  SAFE_FLAGS = FLAGS[:invite_users]

  attr_writer :current_account

  validates :name, presence: true, unless: :everyone?
  validates :color, format: { with: /\A#?(?:[A-F0-9]{3}){1,2}\z/i }, unless: -> { color.blank? }

  validate :validate_permissions_elevation
  validate :validate_dangerous_permissions

  before_validation :set_position

  scope :assignable, -> { where.not(id: -99).order(position: :asc) }

  has_many :users, inverse_of: :role, foreign_key: 'role_id', dependent: :nullify

  def self.nobody
    @nobody ||= UserRole.new(permissions: 0, position: -1)
  end

  def self.everyone
    UserRole.find(-99)
  rescue ActiveRecord::RecordNotFound
    UserRole.create!(id: -99, permissions: FLAGS[:invite_users])
  end

  def everyone?
    id == -99
  end

  def permissions_as_keys
    FLAGS.keys.select { |privilege| permissions & FLAGS[privilege] == FLAGS[privilege] }.map(&:to_s)
  end

  def permissions_as_keys=(value)
    self.permissions = value.map(&:presence).compact.reduce(0) { |bitmask, privilege| FLAGS.key?(privilege.to_sym) ? (bitmask | FLAGS[privilege.to_sym]) : bitmask }
  end

  def can?(*privileges)
    in_permissions?(:administrator) || privileges.any? { |privilege| in_permissions?(privilege) }
  end

  def overrides?(other_role)
    other_role.nil? || position > other_role.position
  end

  def computed_permissions
    @computed_permissions ||= self.class.everyone.permissions | permissions
  end

  private

  def in_permissions?(privilege)
    raise ArgumentError, "Unknown privilege: #{privilege}" unless FLAGS.key?(privilege)
    computed_permissions & FLAGS[privilege] == FLAGS[privilege]
  end

  def set_position
    self.position = -1 if everyone?
  end

  def validate_permissions_elevation
    errors.add(:permissions_as_keys, :elevated) if defined?(@current_account) && @current_account.user_role.permissions & permissions != permissions
  end

  def validate_dangerous_permissions
    errors.add(:permissions_as_keys, :dangerous) if everyone? && SAFE_FLAGS & permissions != permissions
  end
end
