# frozen_string_literal: true

class ScopeTransformer < Parslet::Transform
  class Scope
    PROFILE_TERM   = 'profile'
    DEFAULT_TERM   = 'all'
    DEFAULT_ACCESS = %w(read write).freeze
    READ_ONLY_ACCESS = %w(read).freeze

    attr_reader :namespace, :term

    def initialize(scope)
      @namespace = scope[:namespace]&.to_s
      @term      = scope[:term]&.to_s || DEFAULT_TERM

      # override for profile scope which is read only
      @access = if @term == PROFILE_TERM
                  READ_ONLY_ACCESS.dup
                else
                  scope[:access] ? [scope[:access].to_s] : DEFAULT_ACCESS.dup
                end
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

      @access.concat(other_scope.instance_variable_get(:@access))
      @access.uniq!
      @access.sort!

      self
    end
  end

  rule(scope: subtree(:scope)) { Scope.new(scope) }
end
