require "active_support/core_ext/array/conversions"

module Pundit
  module RSpec
    module Matchers
      extend ::RSpec::Matchers::DSL

      matcher :permit do |user, record|
        match_proc = lambda do |policy|
          @violating_permissions = permissions.find_all do |permission|
            not policy.new(user, record).public_send(permission)
          end
          @violating_permissions.empty?
        end

        match_when_negated_proc = lambda do |policy|
          @violating_permissions = permissions.find_all do |permission|
            policy.new(user, record).public_send(permission)
          end
          @violating_permissions.empty?
        end

        failure_message_proc = lambda do |policy|
          was_were = @violating_permissions.count > 1 ? "were" : "was"
          "Expected #{policy} to grant #{permissions.to_sentence} on \
          #{record} but #{@violating_permissions.to_sentence} #{was_were} not granted"
        end

        failure_message_when_negated_proc = lambda do |policy|
          was_were = @violating_permissions.count > 1 ? "were" : "was"
          "Expected #{policy} not to grant #{permissions.to_sentence} on \
          #{record} but #{@violating_permissions.to_sentence} #{was_were} granted"
        end

        if respond_to?(:match_when_negated)
          match(&match_proc)
          match_when_negated(&match_when_negated_proc)
          failure_message(&failure_message_proc)
          failure_message_when_negated(&failure_message_when_negated_proc)
        else
          match_for_should(&match_proc)
          match_for_should_not(&match_when_negated_proc)
          failure_message_for_should(&failure_message_proc)
          failure_message_for_should_not(&failure_message_when_negated_proc)
        end

        def permissions
          current_example = ::RSpec.respond_to?(:current_example) ? ::RSpec.current_example : example
          current_example.metadata[:permissions]
        end
      end
    end

    module DSL
      def permissions(*list, &block)
        describe(list.to_sentence, permissions: list, caller: caller) { instance_eval(&block) }
      end
    end

    module PolicyExampleGroup
      include Pundit::RSpec::Matchers

      def self.included(base)
        base.metadata[:type] = :policy
        base.extend Pundit::RSpec::DSL
        super
      end
    end
  end
end

RSpec.configure do |config|
  if RSpec::Core::Version::STRING.split(".").first.to_i >= 3
    config.include(Pundit::RSpec::PolicyExampleGroup,
      type: :policy,
      file_path: %r{spec/policies}
    )
  else
    config.include(Pundit::RSpec::PolicyExampleGroup,
      type: :policy,
      example_group: { file_path: %r{spec/policies} }
    )
  end
end
