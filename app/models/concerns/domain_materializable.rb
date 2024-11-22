# frozen_string_literal: true

module DomainMaterializable
  extend ActiveSupport::Concern

  include Redisable

  included do
    after_create_commit :refresh_instances_view
  end

  def refresh_instances_view
    return if domain.nil? || Instance.exists?(domain: domain)

    Instance.refresh
    count_unique_subdomains!
  end

  def count_unique_subdomains!
    second_and_top_level_domain = PublicSuffix.domain(domain, ignore_private: true)
    with_redis do |redis|
      redis.pfadd("unique_subdomains_for:#{second_and_top_level_domain}", domain)
      redis.expire("unique_subdomains_for:#{second_and_top_level_domain}", 1.minute.seconds)
    end
  end
end
