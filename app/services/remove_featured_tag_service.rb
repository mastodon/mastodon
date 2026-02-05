# frozen_string_literal: true

class RemoveFeaturedTagService < BaseService
  include Payloadable

  def call(account, featured_tag_or_tag)
    raise ArgumentError unless account.local?

    @account = account

    @featured_tag = begin
      if featured_tag_or_tag.is_a?(FeaturedTag)
        featured_tag_or_tag
      elsif featured_tag_or_tag.is_a?(Tag)
        FeaturedTag.find_by(account: account, tag: featured_tag_or_tag)
      end
    end

    return if @featured_tag.nil?

    @featured_tag.destroy!

    ActivityPub::AccountRawDistributionWorker.perform_async(build_json(@featured_tag), account.id) if @account.local?
  end

  private

  def build_json(featured_tag)
    Oj.dump(serialize_payload(featured_tag, ActivityPub::RemoveHashtagSerializer, signer: @account))
  end
end
