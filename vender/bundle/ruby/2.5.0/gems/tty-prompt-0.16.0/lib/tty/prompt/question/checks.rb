# encoding: utf-8
# frozen_string_literal: true

module TTY
  class Prompt
    class Question
      module Checks
        # Check if modifications are applicable
        class CheckModifier
          def self.call(question, value)
            if !question.modifier.nil? || question.modifier
              [Modifier.new(question.modifier).apply_to(value)]
            else
              [value]
            end
          end
        end

        # Check if value is within range
        class CheckRange
          def self.float?(value)
            !/[-+]?(\d*[.])?\d+/.match(value.to_s).nil?
          end

          def self.int?(value)
            !/^[-+]?\d+$/.match(value.to_s).nil?
          end

          def self.cast(value)
            if float?(value)
              value.to_f
            elsif int?(value)
              value.to_i
            else
              value
            end
          end

          def self.call(question, value)
            if !question.in? ||
              (question.in? && question.in.include?(cast(value)))
              [value]
            else
              tokens = {value: value, in: question.in}
              [value, question.message_for(:range?, tokens)]
            end
          end
        end

        # Check if input requires validation
        class CheckValidation
          def self.call(question, value)
            if !question.validation? || (question.required? && value.nil?) ||
              (question.validation? &&
                Validation.new(question.validation).call(value))
              [value]
            else
              tokens = {valid: question.validation.inspect}
              [value, question.message_for(:valid?, tokens)]
            end
          end
        end

        # Check if default value provided
        class CheckDefault
          def self.call(question, value)
            if value.nil? && question.default?
              [question.default]
            else
              [value]
            end
          end
        end

        # Check if input is required
        class CheckRequired
          def self.call(question, value)
            if question.required? && !question.default? && value.nil?
              [value, question.message_for(:required?)]
            else
              [value]
            end
          end
        end
      end # Checks
    end # Question
  end # Prompt
end # TTY
