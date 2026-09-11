# frozen_string_literal: true

class ActivityPub::Parser::InteractionPolicyParser
  def initialize(json, account)
    @json = json
    @account = account
  end

  def bitmap
    flags = 0
    return flags if @json.blank?

    flags |= subpolicy(@json['automaticApproval'])
    flags <<= 16
    flags |= subpolicy(@json['manualApproval'])

    flags
  end

  private

  def subpolicy(partial_json)
    flags = 0

    allowed_actors = Array(partial_json).dup
    allowed_actors.uniq!

    flags |= InteractionPolicy::POLICY_FLAGS[:public] if allowed_actors.delete('as:Public') || allowed_actors.delete('Public') || allowed_actors.delete('https://www.w3.org/ns/activitystreams#Public')
    flags |= InteractionPolicy::POLICY_FLAGS[:followers] if allowed_actors.delete(@account.followers_url)
    flags |= InteractionPolicy::POLICY_FLAGS[:following] if allowed_actors.delete(@account.following_url)

    includes_target_actor = allowed_actors.delete(ActivityPub::TagManager.instance.uri_for(@account)).present?

    # Any unrecognized actor is marked as unsupported
    flags |= InteractionPolicy::POLICY_FLAGS[:unsupported_policy] unless allowed_actors.empty?

    flags |= InteractionPolicy::POLICY_FLAGS[:disabled] if flags.zero? && includes_target_actor

    flags
  end
end
