# frozen_string_literal: true

class Redis
  module NamespaceExtensions
    def exists?(*args, &block)
      call_with_namespace('exists?', *args, &block)
    end

    def with
      yield self
    end
  end
end

Redis::Namespace::COMMANDS['exists?'] = [:first]
Redis::Namespace.prepend(Redis::NamespaceExtensions)
