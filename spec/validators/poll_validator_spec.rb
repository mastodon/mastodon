# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollValidator, type: :validator do
  describe '#validate' do
    before do
      validator.validate(poll)
    end

    let(:validator) { described_class.new }
    let(:poll) { double(options: options, expires_at: expires_at, errors: errors) }
    let(:errors) { double(add: nil) }
    let(:options) { %w(foo bar) }
    let(:expires_at) { 1.day.from_now }

    it 'have no errors' do
      expect(errors).to_not have_received(:add)
    end

    context 'when expires is just 5 min ago' do
      let(:expires_at) { 5.minutes.from_now }

      it 'not calls errors add' do
        expect(errors).to_not have_received(:add)
      end
    end
  end
end
