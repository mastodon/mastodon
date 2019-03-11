# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  SUPPORTED_TYPES = %w(Application Group Organization Person Service).freeze

  def perform
    update_account if equals_or_includes_any?(@object['type'], SUPPORTED_TYPES)
    update_poll if equals_or_includes_any?(@object['type'], %w(Question))
  end

  private

  def update_account
    return if @account.uri != object_uri

    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object, signed_with_known_key: true)
  end

  def update_poll
    return reject_payload! if invalid_origin?(@object['id'])
    status = Status.find_by(uri: object_uri, account_id: @account.id)
    return if status.nil? || status.poll_id.nil?
    poll = Poll.find(status.poll_id)
    return if poll.nil?

    ActivityPub::ProcessPollService.new.call(poll, @object)
  end
end
