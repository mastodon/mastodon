# frozen_string_literal: true

class FeaturedTagService < BaseService
  include Payloadable

  def call(account, name)
    @account = account

    FeaturedTag.create!(account: account, name: name).tap do |featured_tag|
      ActivityPub::AccountRawDistributionWorker.perform_async(build_json(featured_tag), account.id) if @account.local?
    end
  rescue ActiveRecord::RecordNotUnique
    FeaturedTag.by_name(name).find_by!(account: account)
  end

  private

  def build_json(featured_tag)
    Oj.dump(serialize_payload(featured_tag, ActivityPub::AddHashtagSerializer, signer: @account))
  end
end
