# frozen_string_literal: true

class CreateFeaturedTagService < BaseService
  include Payloadable

  def call(account, name_or_tag, raise_error: true)
    raise ArgumentError unless account.local?

    @account = account

    @featured_tag = begin
      if name_or_tag.is_a?(Tag)
        account.featured_tags.find_or_initialize_by(tag: name_or_tag)
      else
        account.featured_tags.find_or_initialize_by(name: name_or_tag)
      end
    end

    create_method = raise_error ? :save! : :save

    ActivityPub::AccountRawDistributionWorker.perform_async(build_json(@featured_tag), @account.id) if @featured_tag.new_record? && @featured_tag.public_send(create_method)

    @featured_tag
  end

  private

  def build_json(featured_tag)
    Oj.dump(serialize_payload(featured_tag, ActivityPub::AddHashtagSerializer, signer: @account))
  end
end
