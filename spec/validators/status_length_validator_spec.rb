# frozen_string_literal: true

require 'rails_helper'

describe StatusLengthValidator do
  describe '#validate' do
    it 'does not add errors onto remote statuses'
    it 'does not add errors onto local reblogs'

    it 'adds an error when content warning is over 500 characters' do
      status = double(spoiler_text: 'a' * 520, text: '', errors: double(add: nil), local?: true, reblog?: false)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'adds an error when text is over 500 characters' do
      status = double(spoiler_text: '', text: 'a' * 520, errors: double(add: nil), local?: true, reblog?: false)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'adds an error when text and content warning are over 500 characters total' do
      status = double(spoiler_text: 'a' * 250, text: 'b' * 251, errors: double(add: nil), local?: true, reblog?: false)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'counts URLs as 23 characters flat' do
      text   = ('a' * 476) + " http://#{'b' * 30}.com/example"
      status = double(spoiler_text: '', text: text, errors: double(add: nil), local?: true, reblog?: false)

      subject.validate(status)
      expect(status.errors).to_not have_received(:add)
    end

    it 'counts only the front part of remote usernames' do
      text   = ('a' * 475) + " @alice@#{'b' * 30}.com"
      status = double(spoiler_text: '', text: text, errors: double(add: nil), local?: true, reblog?: false)

      subject.validate(status)
      expect(status.errors).to_not have_received(:add)
    end
  end
end
