# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  SUPPORTED_TYPES = %w(Application Group Organization Person Service).freeze

  def perform
    if equals_or_includes_any?(@object['type'], SUPPORTED_TYPES)
      update_account
    elsif equals_or_includes_any?(@object['type'], %w(Question))
      update_poll
    end
  end

  private

  def update_account
    return if @account.uri != object_uri

    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object, signed_with_known_key: true)
  end

  def update_poll
    return reject_payload! if invalid_origin?(@object['id'])

    status = Status.find_by(uri: object_uri, account_id: @account.id)
    return if status.nil? || status.poll.nil?

    ActivityPub::ProcessPollService.new.call(status.poll, @object)
  end
end
