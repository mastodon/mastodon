# frozen_string_literal: true

# == Schema Information
#
# Table name: keypairs
#
#  id             :bigint(8)        not null, primary key
#  expires_at     :datetime
#  local_fragment :string
#  private_key    :string
#  public_key     :string           not null
#  revoked        :boolean          default(FALSE), not null
#  type           :integer          not null
#  uri            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :bigint(8)        not null
#

class Keypair < ApplicationRecord
  include Expireable

  self.inheritance_column = nil

  encrypts :private_key

  belongs_to :account

  enum :type, {
    rsa: 0,
    ed25519: 1,
  }, validate: true

  attr_accessor :require_private_key

  validates :uri, presence: true, uniqueness: true, if: -> { account.remote? }
  validates :uri, absence: true, if: -> { account.local? }

  validates :local_fragment, presence: true, uniqueness: { scope: :account_id }, format: { with: /\A#[A-Z0-9-]+\Z/i }, if: -> { account.local? }
  validates :local_fragment, absence: true, if: -> { account.remote? }

  validates :public_key, presence: true
  validates :private_key, presence: true, if: -> { account.local? }

  # NOTE: this should be true in production, but tests heavily rely on remote accounts having a keypair
  validates :private_key, absence: true, if: -> { account.remote? && !require_private_key }

  scope :unexpired, -> { where(expires_at: nil).or(where.not(expires_at: ..Time.now.utc)) }
  scope :usable, -> { unexpired.where(revoked: false) }

  alias actor account

  def full_uri
    return ActivityPub::TagManager.instance.uri_for(account) + local_fragment if local_fragment.present?

    uri
  end

  def keypair
    @keypair ||= begin
      case type
      when 'rsa'
        OpenSSL::PKey::RSA.new(private_key || public_key)
      when 'ed25519'
        OpenSSL::PKey.read(private_key || public_key)
      end
    end
  end

  def usable?
    !revoked? && !expired?
  end

  def self.from_keyid(uri)
    return if uri.blank?

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

  def self.from_worker_arg(account, private_key_pem_or_hash)
    if private_key_pem_or_hash.is_a?(String)
      account.keypairs.build(
        private_key: private_key_pem_or_hash,
        local_fragment: '#main-key',
        type: :rsa
      )
    else
      account.keypairs.build(
        private_key: private_key_pem_or_hash['private_key'],
        public_key: private_key_pem_or_hash['public_key'],
        uri: private_key_pem_or_hash['uri'],
        local_fragment: private_key_pem_or_hash['local_fragment'],
        type: private_key_pem_or_hash['type']
      )
    end
  end
end
