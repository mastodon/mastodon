# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserEmailValidator do
  subject { Fabricate.build :user, confirmed_at: nil }

  context 'when email provider is blocked' do
    before { Fabricate :email_domain_block, domain: 'mail.com' }

    it { is_expected.to_not allow_value('info@mail.com').for(:email).with_message(:blocked) }
  end

  context 'when email provider is not blocked' do
    it { is_expected.to allow_value('info@mail.com').for(:email) }
  end

  context 'when canonical email address is blocked' do
    let(:other_user) { Fabricate(:user, email: 'i.n.f.o@mail.com') }

    before { other_user.account.suspend! }

    it { is_expected.to_not allow_value('info@mail.com').for(:email).with_message(:taken) }
  end
end
