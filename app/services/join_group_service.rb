# frozen_string_literal: true

class JoinGroupService < BaseService
  include Redisable
  include Payloadable
  include DomainControlHelper

  # @param [Account] account Account from which to join
  # @param [Group] Group to join
  def call(account, group)
    @account = account
    @group   = group

    raise ActiveRecord::RecordNotFound if joining_not_possible?
    raise Mastodon::NotPermittedError  if joining_not_allowed?

    if @group.locked? || @account.silenced? || !@group.local?
      request_join!
    elsif @group.local?
      direct_join!
    end
  end

  private

  def joining_not_possible?
    @group.nil? || @group.suspended?
  end

  def joining_not_allowed?
    domain_not_allowed?(@group.domain) || @group.blocking?(@account) || @account.domain_blocking?(@group.domain)
  end

  def request_join!
    membership_request = @group.membership_requests.create!(account: @account)

    if @group.local?
      # TODO: notifications
    else
      ActivityPub::DeliveryWorker.perform_async(build_json(membership_request), @account.id, @group.inbox_url)
    end

    membership_request
  end

  def direct_join!
    membership = @group.memberships.create!(account: @account)

    distribute_add_to_remote_members! if @group.local?
    # TODO: notifications

    membership
  end

  def distribute_add_to_remote_members!
    json = Oj.dump(serialize_payload(@account, ActivityPub::AddSerializer, target: ActivityPub::TagManager.instance.members_uri_for(@group), actor: ActivityPub::TagManager.instance.uri_for(@group)))
    ActivityPub::GroupRawDistributionWorker.perform_async(json, @group.id, [@account.inbox_url])
  end

  def build_json(membership_request)
    Oj.dump(serialize_payload(membership_request, ActivityPub::JoinSerializer))
  end
end
