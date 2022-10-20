# frozen_string_literal: true

class UnfeaturedTagWorker
  include Sidekiq::Worker

  def perform(account_id, featured_tag_id)
    UnfeaturedTagService.new.call(Account.find(account_id), FeaturedTag.find(featured_tag_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
