require "sidekiq"
require "active_support/core_ext/array/grouping"

module SidekiqBulk
  def push_bulk(items, limit: 10_000, &block)
    items.in_groups_of(limit, false).each do |group|
      push_bulk!(group, &block)
    end
  end

  def push_bulk!(items, &block)
    if block
      args = items.map(&block)
    else
      args = items.map { |el| [el] }
    end

    Sidekiq::Client.push_bulk("class" => self, "args" => args)
  end
end

Sidekiq::Worker::ClassMethods.module_eval { include SidekiqBulk }
