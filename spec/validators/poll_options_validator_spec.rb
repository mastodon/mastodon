# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollOptionsValidator do
  describe '#validate' do
    before do
      validator.validate(poll)
    end

    let(:validator) { described_class.new }
    let(:poll) { instance_double(Poll, options: options, expires_at: expires_at, errors: errors) }
    let(:errors) { instance_double(ActiveModel::Errors, add: nil) }
    let(:options) { %w(foo bar) }
    let(:expires_at) { 1.day.from_now }

    it 'has no errors' do
      expect(errors).to_not have_received(:add)
    end

    context 'when the poll has duplicate options' do
      let(:options) { %w(foo foo) }

      it 'adds errors' do
        expect(errors).to have_received(:add)
      end
    end

    context 'when the poll has no options' do
      let(:options) { [] }

      it 'adds errors' do
        expect(errors).to have_received(:add)
      end
    end

    context 'when the poll has too many options' do
      let(:options) { Array.new(described_class::MAX_OPTIONS + 1) { |i| "option #{i}" } }

      it 'adds errors' do
        expect(errors).to have_received(:add)
      end
    end

    describe 'character length of poll options' do
      context 'when poll has acceptable length options' do
        let(:options) { %w(test this) }

        it 'has no errors' do
          expect(errors).to_not have_received(:add)
        end
      end

      context 'when poll has multibyte and ZWJ emoji options' do
        let(:options) { ['✨' * described_class::MAX_OPTION_CHARS, '🏳️‍⚧️' * described_class::MAX_OPTION_CHARS] }

        it 'has no errors' do
          expect(errors).to_not have_received(:add)
        end
      end

      context 'when poll has options that are too long' do
        let(:options) { ['ok', 'a' * (described_class::MAX_OPTION_CHARS**2)] }

        it 'has errors' do
          expect(errors).to have_received(:add)
        end
      end
    end
  end
end
