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
    manage_user_access: (1 << 18),
    delete_user_data: (1 << 19),
  }.freeze

  EVERYONE_ROLE_ID = -99
  NOBODY_POSITION = -1

  module Flags
    NONE = 0
    ALL  = FLAGS.values.reduce(&:|)

    DEFAULT = FLAGS[:invite_users]

    CATEGORIES = {
      invites: %i(
        invite_users
      ).freeze,

      moderation: %i(
        view_dashboard
        view_audit_log
        manage_users
        manage_user_access
        delete_user_data
        manage_reports
        manage_appeals
        manage_federation
        manage_blocks
        manage_taxonomies
        manage_invites
      ).freeze,

      administration: %i(
        manage_settings
        manage_rules
        manage_roles
        manage_webhooks
        manage_custom_emojis
        manage_announcements
      ).freeze,

      devops: %i(
        view_devops
      ).freeze,

      special: %i(
        administrator
      ).freeze,
    }.freeze
  end

  attr_writer :current_account

  validates :name, presence: true, unless: :everyone?
  validates :color, format: { with: /\A#?(?:[A-F0-9]{3}){1,2}\z/i }, unless: -> { color.blank? }

  validate :validate_permissions_elevation
  validate :validate_position_elevation
  validate :validate_dangerous_permissions
  validate :validate_own_role_edition

  before_validation :set_position

  scope :assignable, -> { where.not(id: EVERYONE_ROLE_ID).order(position: :asc) }
  scope :highlighted, -> { where(highlighted: true) }
  scope :with_color, -> { where.not(color: [nil, '']) }
  scope :providing_styles, -> { highlighted.with_color }

  has_many :users, inverse_of: :role, foreign_key: 'role_id', dependent: :nullify

  def self.nobody
    @nobody ||= UserRole.new(permissions: Flags::NONE, position: NOBODY_POSITION)
  end

  def self.everyone
    UserRole.find(EVERYONE_ROLE_ID)
  rescue ActiveRecord::RecordNotFound
    UserRole.create!(id: EVERYONE_ROLE_ID, permissions: Flags::DEFAULT)
  end

  def self.that_can(*any_of_privileges)
    all.select { |role| role.can?(*any_of_privileges) }
  end

  def everyone?
    id == EVERYONE_ROLE_ID
  end

  def nobody?
    id.nil?
  end

  def permissions_as_keys
    FLAGS.keys.select { |privilege| permissions & FLAGS[privilege] == FLAGS[privilege] }.map(&:to_s)
  end

  def permissions_as_keys=(value)
    self.permissions = value.filter_map(&:presence).reduce(Flags::NONE) { |bitmask, privilege| FLAGS.key?(privilege.to_sym) ? (bitmask | FLAGS[privilege.to_sym]) : bitmask }
  end

  def can?(*any_of_privileges)
    any_of_privileges.any? { |privilege| in_permissions?(privilege) }
  end

  def overrides?(other_role)
    other_role.nil? || position > other_role.position
  end

  def bypass_block?(role)
    overrides?(role) && highlighted? && can?(*Flags::CATEGORIES[:moderation])
  end

  def computed_permissions
    # If called on the everyone role, no further computation needed
    return permissions if everyone?

    # If called on the nobody role, no permissions are there to be given
    return Flags::NONE if nobody?

    # Otherwise, compute permissions based on special conditions
    @computed_permissions ||= begin
      permissions = self.class.everyone.permissions | self.permissions

      if permissions & FLAGS[:administrator] == FLAGS[:administrator]
        Flags::ALL
      else
        permissions
      end
    end
  end

  def to_log_human_identifier
    name
  end

  private

  def in_permissions?(privilege)
    raise ArgumentError, "Unknown privilege: #{privilege}" unless FLAGS.key?(privilege)

    computed_permissions & FLAGS[privilege] == FLAGS[privilege]
  end

  def set_position
    self.position = NOBODY_POSITION if everyone?
  end

  def validate_own_role_edition
    return unless defined?(@current_account) && @current_account.user_role.id == id

    errors.add(:permissions_as_keys, :own_role) if permissions_changed?
    errors.add(:position, :own_role) if position_changed?
  end

  def validate_permissions_elevation
    errors.add(:permissions_as_keys, :elevated) if defined?(@current_account) && @current_account.user_role.computed_permissions & permissions != permissions
  end

  def validate_position_elevation
    errors.add(:position, :elevated) if defined?(@current_account) && @current_account.user_role.position < position
  end

  def validate_dangerous_permissions
    errors.add(:permissions_as_keys, :dangerous) if everyone? && Flags::DEFAULT & permissions != permissions
  end
end
