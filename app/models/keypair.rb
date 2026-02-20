# frozen_string_literal: true

# == Schema Information
#
# Table name: keypairs
#
#  id          :bigint(8)        not null, primary key
#  expires_at  :datetime
#  private_key :string
#  public_key  :string           not null
#  revoked     :boolean          default(FALSE), not null
#  type        :integer          not null
#  uri         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint(8)        not null
#

class Keypair < ApplicationRecord
  include Expireable

  self.inheritance_column = nil

  encrypts :private_key

  belongs_to :account

  enum :type, { rsa: 0 }

  attr_accessor :require_private_key

  validates :uri, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :private_key, presence: true, if: -> { account.local? }

  # NOTE: this should be true in production, but tests heavily rely on remote accounts having a keypair
  validates :private_key, absence: true, if: -> { account.remote? && !require_private_key }

  scope :unexpired, -> { where(expires_at: nil).or(where.not(expires_at: ..Time.now.utc)) }
  scope :usable, -> { unexpired.where(revoked: false) }

  alias actor account

  def keypair
    @keypair ||= begin
      case type
      when 'rsa'
        OpenSSL::PKey::RSA.new(private_key || public_key)
      end
    end
  end

  def usable?
    !revoked? && !expired?
  end

  def self.from_keyid(uri)
    keypair = find_by(uri: uri)
    return keypair unless keypair.nil?

    # No keypair found, try the old way we used to store RSA keypairs
    account = ActivityPub::TagManager.instance.uri_to_actor(uri)
    return if account&.public_key.blank?

    from_legacy_account(account, uri: uri)
  end

  def self.from_legacy_account(account, uri: nil)
    Keypair.new(
      account:,
      uri: uri.presence || ActivityPub::TagManager.instance.key_uri_for(account),
      public_key: account.public_key,
      private_key: account.private_key,
      type: :rsa
    )
  end
end
