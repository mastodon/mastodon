# frozen_string_literal: true

class CreateFeaturedTagService < BaseService
  include Payloadable

  def call(account, name, force: true)
    @account = account

    FeaturedTag.create!(account: account, name: name).tap do |featured_tag|
      ActivityPub::AccountRawDistributionWorker.perform_async(build_json(featured_tag), account.id) if @account.local?
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
    if force && e.is_a(ActiveRecord::RecordNotUnique)
      FeaturedTag.by_name(name).find_by!(account: account)
    else
      account.featured_tags.new(name: name)
    end
  end

  private

  def build_json(featured_tag)
    Oj.dump(serialize_payload(featured_tag, ActivityPub::AddSerializer, signer: @account))
  end
end
