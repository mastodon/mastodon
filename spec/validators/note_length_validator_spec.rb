# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoteLengthValidator do
  subject { described_class.new(attributes: { note: true }, maximum: 500) }

  describe '#validate' do
    it 'adds an error when text is over configured character limit' do
      text = 'a' * 520
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to have_received(:add)
    end

    it 'reduces calculated length of auto-linkable space-separated URLs' do
      text = [starting_string, example_link].join(' ')
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to_not have_received(:add)
    end

    it 'does not reduce calculated length of non-autolinkable URLs' do
      text = [starting_string, example_link].join
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to have_received(:add)
    end

    it 'counts multi byte emoji as single character' do
      text = '✨' * 500
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to_not have_received(:add)
    end

    it 'counts ZWJ sequence emoji as single character' do
      text = '🏳️‍⚧️' * 500
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to_not have_received(:add)
    end

    private

    def starting_string
      'a' * 476
    end

    def example_link
      "http://#{'b' * 30}.com/example"
    end

    def activemodel_errors
      instance_double(ActiveModel::Errors, add: nil)
    end
  end
end
