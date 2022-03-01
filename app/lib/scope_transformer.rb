# frozen_string_literal: true

class ScopeTransformer < Parslet::Transform
  class Scope
    DEFAULT_TERM   = 'all'
    DEFAULT_ACCESS = %w(read write).freeze

    attr_reader :namespace, :term

    def initialize(scope)
      @namespace = scope[:namespace]&.to_s
      @access    = scope[:access] ? [scope[:access].to_s] : DEFAULT_ACCESS.dup
      @term      = scope[:term]&.to_s || DEFAULT_TERM
    end

    def key
      @key ||= [@namespace, @term].compact.join('/')
    end

    def access
      @access.join('/')
    end

    def merge(other_scope)
      clone.merge!(other_scope)
    end

    def merge!(other_scope)
      raise ArgumentError unless other_scope.namespace == namespace && other_scope.term == term

      @access.concat(other_scope.instance_variable_get('@access'))
      @access.uniq!
      @access.sort!

      self
    end
  end

  rule(scope: subtree(:scope)) { Scope.new(scope) }
end
