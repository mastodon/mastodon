# frozen_string_literal: true

require 'rails_helper'

describe NoteLengthValidator do
  subject { NoteLengthValidator.new(attributes: { note: true }, maximum: 500) }

  describe '#validate' do
    it 'adds an error when text is over 500 characters' do
      text = 'a' * 520
      account = double(note: text, errors: double(add: nil))

      subject.validate_each(account, 'note', text)
      expect(account.errors).to have_received(:add)
    end

    it 'counts URLs as 23 characters flat' do
      text   = ('a' * 476) + " http://#{'b' * 30}.com/example"
      account = double(note: text, errors: double(add: nil))

      subject.validate_each(account, 'note', text)
      expect(account.errors).to_not have_received(:add)
    end

    it 'does not count non-autolinkable URLs as 23 characters flat' do
      text   = ('a' * 476) + "http://#{'b' * 30}.com/example"
      account = double(note: text, errors: double(add: nil))

      subject.validate_each(account, 'note', text)
      expect(account.errors).to have_received(:add)
    end
  end
end
