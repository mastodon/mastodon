# frozen_string_literal: true

require 'rails_helper'
require 'i18n/tasks'

describe 'I18n' do
  # Copied from $(bundle exec i18n-tasks gem-path)/templates/rspec/i18n_spec.rb
  describe I18n do
    let(:i18n) { I18n::Tasks::BaseTask.new }
    let(:missing_keys) { i18n.missing_keys }
    let(:unused_keys) { i18n.unused_keys }
    let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

    # Fails because only EN files are currently enforced
    # it 'does not have missing keys' do
    #   expect(missing_keys).to be_empty,
    #                           "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
    # end

    it 'does not have unused keys' do
      expect(unused_keys).to be_empty,
                             "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
    end

    it 'files are normalized' do
      non_normalized = i18n.non_normalized_paths
      error_message = "The following files need to be normalized:\n" \
                      "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                      "Please run `i18n-tasks normalize' to fix"
      expect(non_normalized).to be_empty, error_message
    end

    it 'does not have inconsistent interpolations' do
      error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                      "Run `i18n-tasks check-consistent-interpolations' to show them"
      expect(inconsistent_interpolations).to be_empty, error_message
    end
  end

  describe 'Pluralizing locale translations' do
    subject { I18n.t('generic.validation_errors', count: 1) }

    context 'with the `en` locale which has `one` and `other` plural values' do
      around do |example|
        I18n.with_locale(:en) do
          example.run
        end
      end

      it 'translates to `en` correctly and without error' do
        expect { subject }.to_not raise_error
        expect(subject).to match(/the error below/)
      end
    end

    context 'with the `my` locale which has only `other` plural value' do
      around do |example|
        I18n.with_locale(:my) do
          example.run
        end
      end

      it 'translates to `my` correctly and without error' do
        expect { subject }.to_not raise_error
        expect(subject).to match(/1/)
      end
    end
  end
end
