# == Schema Information
#
# Table name: groups
#
#  id                           :bigint(8)        not null, primary key
#  domain                       :string
#  url                          :string
#  note                         :text             default(""), not null
#  display_name                 :string           default(""), not null
#  locked                       :boolean          default(FALSE), not null
#  hide_members                 :boolean          default(FALSE), not null
#  suspended_at                 :datetime
#  suspension_origin            :integer
#  discoverable                 :boolean
#  avatar_file_name             :string
#  avatar_content_type          :string
#  avatar_file_size             :bigint(8)
#  avatar_updated_at            :datetime
#  avatar_remote_url            :string           default(""), not null
#  header_file_name             :string
#  header_content_type          :string
#  header_file_size             :bigint(8)
#  header_updated_at            :datetime
#  header_remote_url            :string           default(""), not null
#  image_storage_schema_version :integer
#  uri                          :string
#  outbox_url                   :string           default(""), not null
#  inbox_url                    :string           default(""), not null
#  shared_inbox_url             :string           default(""), not null
#  members_url                  :string           default(""), not null
#  wall_url                     :string           default(""), not null
#  private_key                  :text
#  public_key                   :text             default(""), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class Group < ApplicationRecord
  include Attachmentable
  include AccountAvatar
  include AccountHeader
  include Paginable
  include GroupCounters
  include DomainNormalizable
  include DomainMaterializable

  has_many :memberships,  class_name: 'GroupMembership', foreign_key: 'group_id', dependent: :destroy
  has_many :members, -> { order('group_memberships.id desc') }, through: :memberships,  source: :account
  has_many :membership_requests, class_name: 'GroupMembershipRequest', foreign_key: 'group_id', dependent: :destroy
  has_many :account_blocks, class_name: 'GroupAccountBlock', foreign_key: 'group_id', dependent: :destroy
  has_many :statuses, inverse_of: :group, dependent: :destroy
  has_one :deletion_request, class_name: 'GroupDeletionRequest', inverse_of: :group, dependent: :destroy

  scope :recent, -> { reorder(id: :desc) }
  scope :remote, -> { where.not(domain: nil) }
  scope :local,  -> { where(domain: nil) }
  scope :suspended, -> { where.not(suspended_at: nil) }
  scope :without_suspended, -> { where(suspended_at: nil) }
  scope :matches_display_name, ->(value) { where(arel_table[:display_name].matches("#{value}%")) }
  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }

  before_create :generate_keys

  def local?
    domain.nil?
  end

  def remote?
    !local?
  end

  def suspended?
    suspended_at.present?
  end

  def suspended_permanently?
    suspended? && deletion_request.nil?
  end

  def suspended_temporarily?
    suspended? && deletion_request.present?
  end

  def suspend!(date: Time.now.utc, origin: :local)
    transaction do
      create_deletion_request!
      update!(suspended_at: date, suspension_origin: origin)
    end
  end

  def unsuspend!
    transaction do
      deletion_request&.destroy!
      update!(suspended_at: nil, suspension_origin: nil)
    end
  end

  def blocking?(account)
    account_blocks.where(account_id: account.id).exists?
  end

  def self.member_map(target_group_ids, account_id)
    GroupMembership.where(group_id: target_group_ids, account_id: account_id).each_with_object({}) do |membership, mapping|
      mapping[membership.group_id] = { role: membership.role }
    end
  end

  def self.requested_map(target_group_ids, account_id)
    GroupMembershipRequest.where(group_id: target_group_ids, account_id: account_id).each_with_object({}) do |request, mapping|
      mapping[request.group_id] = { }
    end
  end

  def emojis
    @emojis ||= CustomEmoji.from_text(emojifiable_text, domain)
  end

  def object_type
    :group
  end

  def to_param
    id.to_s
  end

  def to_log_human_identifier
    display_name || ActivityPub::TagManager.instance.uri_for(self)
  end

  def save_with_optional_media!
    save!
  rescue ActiveRecord::RecordInvalid => e
    errors = e.record.errors.errors
    errors.each do |err|
      if err.attribute == :avatar
        self.avatar = nil
      elsif err.attribute == :header
        self.header = nil
      end
    end

    save!
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(private_key || public_key)
  end

  private

  def emojifiable_text
    [note, display_name].join(' ')
  end

  def generate_keys
    return unless local? && private_key.blank? && public_key.blank?

    keypair = OpenSSL::PKey::RSA.new(2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end
end
