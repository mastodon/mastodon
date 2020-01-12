# frozen_string_literal: true

class SummarizeAccountService < BaseService
  def call(account)
    raise ArgumentError, 'Must be a local account' unless account.user&.present?

    @account = account
    @user    = account.user

    @sessions   = []
    @following  = []
    @followers  = []
    @invited_by = nil
    @invitees   = []
    @hashes     = []

    summarize_sessions!
    summarize_network!
    summarize_media!

    SecureAccountSummary.create!(
      account_id: @account.id,
      summary: Oj.dump(summary_attributes)
    )
  end

  private

  def summary_attributes
    {
      access: {
        email: @user.email,
        sessions: @sessions.uniq,
      },

      network: {
        following: @following,
        followers: @followers,
        inviter: @invited_by,
        invitees: @invitees,
      },

      media: {
        fingerprints: @hashes.compact.uniq,
      },
    }
  end

  def summarize_sessions!
    remember_current_session!
    remember_last_session!
    remember_other_sessions!
  end

  def summarize_network!
    remember_followers!
    remember_following!
    remember_invitees!
    remember_invited_by!
  end

  def summarize_media!
    fingerprint_avatar!
    fingerprint_header!
    fingerprint_media_attachments!
  end

  def remember_following!
    @account.following.find_each do |account|
      @following << account_uri(account)
    end
  end

  def remember_followers!
    @account.followers.find_each do |account|
      @followers << account_uri(account)
    end
  end

  def remember_invited_by!
    @invited_by = account_uri(@user.invite.user.account) if @user.invite&.user&.account&.present?
  end

  def remember_invitees!
    @user.invites.find_each do |invite|
      invite.users.find_each do |user|
        @invitees << account_uri(user.account)
      end
    end
  end

  def remember_current_session!
    @sessions << ip_and_timestamp(@user.current_sign_in_ip, @user.current_sign_in_at) if @user.current_sign_in_ip&.present?
  end

  def remember_last_session!
    @sessions << ip_and_timestamp(@user.last_sign_in_ip, @user.last_sign_in_at) if @user.last_sign_in_ip&.present?
  end

  def remember_other_sessions!
    @user.session_activations.find_each do |session_activation|
      @sessions << ip_and_timestamp(session_activation.ip, session_activation.updated_at)
    end
  end

  def fingerprint_avatar!
    @hashes << fingerprint_attachment(@account.avatar) if @account.avatar.exists?
  end

  def fingerprint_header!
    @hashes << fingerprint_attachment(@account.header) if @account.header.exists?
  end

  def fingerprint_media_attachments!
    @account.media_attachments.find_each do |media_attachment|
      @hashes << fingerprint_attachment(media_attachment.file)
    end
  end

  CHUNK_SIZE = 16.kilobytes

  def fingerprint_attachment(attachment)
    adapter = Paperclip.io_adapters.for(attachment)
    digest  = Digest::SHA256.new

    while (buffer = adapter.read(CHUNK_SIZE))
      digest.update(buffer)
    end

    digest.hexdigest
  rescue Errno::ENOENT, Seahorse::Client::NetworkingError
    nil
  end

  def account_uri(account)
    ActivityPub::TagManager.instance.uri_for(account)
  end

  def ip_and_timestamp(ip, timestamp)
    [ip&.to_s, timestamp&.iso8601]
  end
end
