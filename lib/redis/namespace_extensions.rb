# frozen_string_literal: true

class Redis
  module NamespaceExtensions
    def exists?(...)
      call_with_namespace('exists?', ...)
    end
  end
end

Redis::Namespace::COMMANDS['exists?'] = [:first]
Redis::Namespace.prepend(Redis::NamespaceExtensions)
