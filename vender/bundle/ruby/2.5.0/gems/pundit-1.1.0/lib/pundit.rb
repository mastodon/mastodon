require "pundit/version"
require "pundit/policy_finder"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/introspection"
require "active_support/dependencies/autoload"

# @api public
module Pundit
  SUFFIX = "Policy"

  # @api private
  module Generators; end

  # @api private
  class Error < StandardError; end

  # Error that will be raiser when authorization has failed
  class NotAuthorizedError < Error
    attr_reader :query, :record, :policy

    def initialize(options = {})
      if options.is_a? String
        message = options
      else
        @query  = options[:query]
        @record = options[:record]
        @policy = options[:policy]

        message = options.fetch(:message) { "not allowed to #{query} this #{record.inspect}" }
      end

      super(message)
    end
  end

  # Error that will be raised if a controller action has not called the
  # `authorize` or `skip_authorization` methods.
  class AuthorizationNotPerformedError < Error; end

  # Error that will be raised if a controller action has not called the
  # `policy_scope` or `skip_policy_scope` methods.
  class PolicyScopingNotPerformedError < AuthorizationNotPerformedError; end

  # Error that will be raised if a policy or policy scope is not defined.
  class NotDefinedError < Error; end

  extend ActiveSupport::Concern

  class << self
    # Retrieves the policy for the given record, initializing it with the
    # record and user and finally throwing an error if the user is not
    # authorized to perform the given action.
    #
    # @param user [Object] the user that initiated the action
    # @param record [Object] the object we're checking permissions of
    # @param record [Symbol] the query method to check on the policy (e.g. `:show?`)
    # @raise [NotAuthorizedError] if the given query method returned false
    # @return [true] Always returns true
    def authorize(user, record, query)
      policy = policy!(user, record)

      unless policy.public_send(query)
        raise NotAuthorizedError, query: query, record: record, policy: policy
      end

      true
    end

    # Retrieves the policy scope for the given record.
    #
    # @see https://github.com/elabs/pundit#scopes
    # @param user [Object] the user that initiated the action
    # @param record [Object] the object we're retrieving the policy scope for
    # @return [Scope{#resolve}, nil] instance of scope class which can resolve to a scope
    def policy_scope(user, scope)
      policy_scope = PolicyFinder.new(scope).scope
      policy_scope.new(user, scope).resolve if policy_scope
    end

    # Retrieves the policy scope for the given record.
    #
    # @see https://github.com/elabs/pundit#scopes
    # @param user [Object] the user that initiated the action
    # @param record [Object] the object we're retrieving the policy scope for
    # @raise [NotDefinedError] if the policy scope cannot be found
    # @return [Scope{#resolve}] instance of scope class which can resolve to a scope
    def policy_scope!(user, scope)
      PolicyFinder.new(scope).scope!.new(user, scope).resolve
    end

    # Retrieves the policy for the given record.
    #
    # @see https://github.com/elabs/pundit#policies
    # @param user [Object] the user that initiated the action
    # @param record [Object] the object we're retrieving the policy for
    # @return [Object, nil] instance of policy class with query methods
    def policy(user, record)
      policy = PolicyFinder.new(record).policy
      policy.new(user, record) if policy
    end

    # Retrieves the policy for the given record.
    #
    # @see https://github.com/elabs/pundit#policies
    # @param user [Object] the user that initiated the action
    # @param record [Object] the object we're retrieving the policy for
    # @raise [NotDefinedError] if the policy cannot be found
    # @return [Object] instance of policy class with query methods
    def policy!(user, record)
      PolicyFinder.new(record).policy!.new(user, record)
    end
  end

  # @api private
  module Helper
    def policy_scope(scope)
      pundit_policy_scope(scope)
    end
  end

  included do
    helper Helper if respond_to?(:helper)
    if respond_to?(:helper_method)
      helper_method :policy
      helper_method :pundit_policy_scope
      helper_method :pundit_user
    end
    if respond_to?(:hide_action)
      hide_action :policy
      hide_action :policy_scope
      hide_action :policies
      hide_action :policy_scopes
      hide_action :authorize
      hide_action :verify_authorized
      hide_action :verify_policy_scoped
      hide_action :permitted_attributes
      hide_action :pundit_user
      hide_action :skip_authorization
      hide_action :skip_policy_scope
      hide_action :pundit_policy_authorized?
      hide_action :pundit_policy_scoped?
    end
  end

  # @return [Boolean] whether authorization has been performed, i.e. whether
  #                   one {#authorize} or {#skip_authorization} has been called
  def pundit_policy_authorized?
    !!@_pundit_policy_authorized
  end

  # @return [Boolean] whether policy scoping has been performed, i.e. whether
  #                   one {#policy_scope} or {#skip_policy_scope} has been called
  def pundit_policy_scoped?
    !!@_pundit_policy_scoped
  end

  # Raises an error if authorization has not been performed, usually used as an
  # `after_action` filter to prevent programmer error in forgetting to call
  # {#authorize} or {#skip_authorization}.
  #
  # @see https://github.com/elabs/pundit#ensuring-policies-are-used
  # @raise [AuthorizationNotPerformedError] if authorization has not been performed
  # @return [void]
  def verify_authorized
    raise AuthorizationNotPerformedError, self.class unless pundit_policy_authorized?
  end

  # Raises an error if policy scoping has not been performed, usually used as an
  # `after_action` filter to prevent programmer error in forgetting to call
  # {#policy_scope} or {#skip_policy_scope} in index actions.
  #
  # @see https://github.com/elabs/pundit#ensuring-policies-are-used
  # @raise [AuthorizationNotPerformedError] if policy scoping has not been performed
  # @return [void]
  def verify_policy_scoped
    raise PolicyScopingNotPerformedError, self.class unless pundit_policy_scoped?
  end

  # Retrieves the policy for the given record, initializing it with the record
  # and current user and finally throwing an error if the user is not
  # authorized to perform the given action.
  #
  # @param record [Object] the object we're checking permissions of
  # @param record [Symbol, nil] the query method to check on the policy (e.g. `:show?`)
  # @raise [NotAuthorizedError] if the given query method returned false
  # @return [true] Always returns true
  def authorize(record, query = nil)
    query ||= params[:action].to_s + "?"

    @_pundit_policy_authorized = true

    policy = policy(record)

    unless policy.public_send(query)
      raise NotAuthorizedError, query: query, record: record, policy: policy
    end

    true
  end

  # Allow this action not to perform authorization.
  #
  # @see https://github.com/elabs/pundit#ensuring-policies-are-used
  # @return [void]
  def skip_authorization
    @_pundit_policy_authorized = true
  end

  # Allow this action not to perform policy scoping.
  #
  # @see https://github.com/elabs/pundit#ensuring-policies-are-used
  # @return [void]
  def skip_policy_scope
    @_pundit_policy_scoped = true
  end

  # Retrieves the policy scope for the given record.
  #
  # @see https://github.com/elabs/pundit#scopes
  # @param record [Object] the object we're retrieving the policy scope for
  # @return [Scope{#resolve}, nil] instance of scope class which can resolve to a scope
  def policy_scope(scope)
    @_pundit_policy_scoped = true
    pundit_policy_scope(scope)
  end

  # Retrieves the policy for the given record.
  #
  # @see https://github.com/elabs/pundit#policies
  # @param record [Object] the object we're retrieving the policy for
  # @return [Object, nil] instance of policy class with query methods
  def policy(record)
    policies[record] ||= Pundit.policy!(pundit_user, record)
  end

  # Retrieves a set of permitted attributes from the policy by instantiating
  # the policy class for the given record and calling `permitted_attributes` on
  # it, or `permitted_attributes_for_{action}` if it is defined. It then infers
  # what key the record should have in the params hash and retrieves the
  # permitted attributes from the params hash under that key.
  #
  # @see https://github.com/elabs/pundit#strong-parameters
  # @param record [Object] the object we're retrieving permitted attributes for
  # @return [Hash{String => Object}] the permitted attributes
  def permitted_attributes(record, action = params[:action])
    param_key = PolicyFinder.new(record).param_key
    policy = policy(record)
    method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
      "permitted_attributes_for_#{action}"
    else
      "permitted_attributes"
    end
    params.require(param_key).permit(policy.public_send(method_name))
  end

  # Cache of policies. You should not rely on this method.
  #
  # @api private
  def policies
    @_pundit_policies ||= {}
  end

  # Cache of policy scope. You should not rely on this method.
  #
  # @api private
  def policy_scopes
    @_pundit_policy_scopes ||= {}
  end

  # Hook method which allows customizing which user is passed to policies and
  # scopes initialized by {#authorize}, {#policy} and {#policy_scope}.
  #
  # @see https://github.com/elabs/pundit#customize-pundit-user
  # @return [Object] the user object to be used with pundit
  def pundit_user
    current_user
  end

private

  def pundit_policy_scope(scope)
    policy_scopes[scope] ||= Pundit.policy_scope!(pundit_user, scope)
  end
end
