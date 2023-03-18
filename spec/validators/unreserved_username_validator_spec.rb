# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnreservedUsernameValidator, type: :validator do
  describe '#validate' do
    before do
      allow(validator).to receive(:reserved_username?) { reserved_username }
      validator.validate(account)
    end

    let(:validator) { described_class.new }
    let(:account)   { double(username: username, errors: errors) }
    let(:errors) { double(add: nil) }

    context '@username.blank?' do
      let(:username) { nil }

      it 'not calls errors.add' do
        expect(errors).to_not have_received(:add).with(:username, any_args)
      end
    end

    context '!@username.blank?' do
      let(:username) { 'f' }

      context 'reserved_username?' do
        let(:reserved_username) { true }

        it 'calls errors.add' do
          expect(errors).to have_received(:add).with(:username, :reserved)
        end
      end

      context '!reserved_username?' do
        let(:reserved_username) { false }

        it 'not calls errors.add' do
          expect(errors).to_not have_received(:add).with(:username, any_args)
        end
      end
    end
  end
end
