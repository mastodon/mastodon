# frozen_string_literal: true

class RemoveFeaturedTagService < BaseService
  include Payloadable

  def call(account, featured_tag)
    @account = account

    featured_tag.destroy!
    ActivityPub::AccountRawDistributionWorker.perform_async(build_json(featured_tag), account.id) if @account.local?
  end

  private

  def build_json(featured_tag)
    Oj.dump(serialize_payload(featured_tag, ActivityPub::RemoveSerializer, signer: @account))
  end
end
