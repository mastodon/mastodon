# frozen_string_literal: true

require 'rails_helper'

describe NoteLengthValidator do
  subject { described_class.new(attributes: { note: true }, maximum: 500) }

  describe '#validate' do
    it 'adds an error when text is over 500 characters' do
      text = 'a' * 520
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to have_received(:add)
    end

    it 'counts URLs as 23 characters flat' do
      text = ('a' * 476) + " http://#{'b' * 30}.com/example"
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to_not have_received(:add)
    end

    it 'does not count non-autolinkable URLs as 23 characters flat' do
      text = ('a' * 476) + "http://#{'b' * 30}.com/example"
      account = instance_double(Account, note: text, errors: activemodel_errors)

      subject.validate_each(account, 'note', text)
      expect(account.errors).to have_received(:add)
    end

    private

    def activemodel_errors
      instance_double(ActiveModel::Errors, add: nil)
    end
  end
end
