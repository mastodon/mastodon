# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklistedEmailValidator, type: :validator do
  describe '#validate' do
    let(:user)   { double(email: 'info@mail.com', errors: errors) }
    let(:errors) { double(add: nil) }

    before do
      allow_any_instance_of(described_class).to receive(:blocked_email?) { blocked_email }
      described_class.new.validate(user)
    end

    context 'blocked_email?' do
      let(:blocked_email) { true }

      it 'calls errors.add' do
        expect(errors).to have_received(:add).with(:email, I18n.t('users.invalid_email'))
      end
    end

    context '!blocked_email?' do
      let(:blocked_email) { false }

      it 'not calls errors.add' do
        expect(errors).not_to have_received(:add).with(:email, I18n.t('users.invalid_email'))
      end
    end
  end
end
