# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklistedEmailValidator do
  describe '#validate' do
    subject { described_class.new.validate(user) }

    let(:user)   { instance_double(User, email: 'info@mail.com', sign_up_ip: '1.2.3.4', errors: errors) }
    let(:errors) { instance_double(ActiveModel::Errors, add: nil) }

    before do
      allow(user).to receive(:valid_invitation?).and_return(false)
      allow(EmailDomainBlock).to receive(:block?) { blocked_email }
    end

    context 'when e-mail provider is blocked' do
      let(:blocked_email) { true }

      it 'adds error' do
        subject

        expect(errors).to have_received(:add).with(:email, :blocked).once
      end
    end

    context 'when e-mail provider is not blocked' do
      let(:blocked_email) { false }

      it 'does not add errors' do
        subject

        expect(errors).to_not have_received(:add)
      end

      context 'when canonical e-mail is blocked' do
        let(:other_user) { Fabricate(:user, email: 'i.n.f.o@mail.com') }

        before do
          other_user.account.suspend!
        end

        it 'adds error' do
          subject

          expect(errors).to have_received(:add).with(:email, :taken).once
        end
      end
    end
  end
end
