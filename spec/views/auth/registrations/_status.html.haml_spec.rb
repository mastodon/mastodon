# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'auth/registrations/_status.html.haml' do
  subject { render 'auth/registrations/status', user:, strikes: }

  let(:user) { Fabricate.build :user }
  let(:strikes) { [] }

  context 'with an unconfirmed user' do
    let(:user) { Fabricate.build :user, confirmed_at: nil }

    it { is_expected.to include(I18n.t('auth.status.confirming')) }
  end

  context 'with an unapproved user' do
    let(:user) { Fabricate.build :user, confirmed_at: 2.days.ago, approved: false }

    it { is_expected.to include(I18n.t('auth.status.pending')) }
  end

  context 'with a moved user account' do
    let(:user) { Fabricate.build :user, confirmed_at: 2.days.ago, approved: true, account: }
    let(:account) { Fabricate :account, moved_to_account: }
    let(:moved_to_account) { Fabricate :account, username: 'hello' }

    it { is_expected.to include(I18n.t('auth.status.redirecting_to', acct: 'hello')) }
  end

  context 'with a suspended user account' do
    let(:user) { Fabricate.build :user, account: Fabricate(:account, suspended_at: 2.days.ago) }

    it { is_expected.to include(I18n.t('user_mailer.warning.explanation.suspend')) }
  end

  context 'with a disabled user' do
    let(:user) { Fabricate.build :user, disabled: true }

    it { is_expected.to include(I18n.t('user_mailer.warning.explanation.disable')) }
  end

  context 'with a silenced user account' do
    let(:user) { Fabricate.build :user, account: Fabricate(:account, silenced_at: 2.days.ago) }

    it { is_expected.to include(I18n.t('user_mailer.warning.explanation.silence')) }
  end

  context 'when strikes targeting user account exist' do
    let(:user) { Fabricate.build :user }

    before { Fabricate :account_warning, target_account: user.account }

    it { is_expected.to include(I18n.t('auth.status.view_strikes')) }
  end
end
