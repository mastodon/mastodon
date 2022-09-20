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

  before_create :generate_keys

  def local?
    domain.nil?
  end

  def suspended?
    suspended_at.present?
  end

  def suspend!(date: Time.now.utc, origin: :local)
    #TODO: schedule deletion
    update!(suspended_at: date, suspension_origin: origin)
  end

  def unsuspend!
    #TODO: unschedule deletion
    update!(suspended_at: nil, suspension_origin: nil)
  end

  def keypair
    @keypair ||= OpenSSL::PKey::RSA.new(private_key || public_key)
  end

  private

  def generate_keys
    return unless local? && private_key.blank? && public_key.blank?

    keypair = OpenSSL::PKey::RSA.new(2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end
end
