# frozen_string_literal: true

module Chewy
  class Strategy
    class Mastodon < Base
      def initialize
        super

        @stash = Hash.new { |hash, key| hash[key] = [] }
      end

      def update(type, objects, _options = {})
        @stash[type].concat(type.root.id ? Array.wrap(objects) : type.adapter.identify(objects)) if Chewy.enabled?
      end

      def leave
        RedisConnection.with do |redis|
          redis.pipelined do |pipeline|
            @stash.each do |type, ids|
              pipeline.sadd("chewy:queue:#{type.name}", ids)
            end
          end
        end
      end
    end
  end
end
