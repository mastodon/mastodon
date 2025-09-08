# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollExpirationValidator do
  subject { Fabricate.build :poll }

  context 'when poll expires in far future' do
    let(:far_future) { 6.months.from_now }

    it { is_expected.to_not allow_value(far_future).for(:expires_at).with_message(I18n.t('polls.errors.duration_too_long')) }
  end

  context 'when poll expires in far past' do
    let(:past_date) { 6.days.ago }

    it { is_expected.to_not allow_value(past_date).for(:expires_at).with_message(I18n.t('polls.errors.duration_too_short')) }
  end

  context 'when poll expires in medium future' do
    let(:allowed_future) { 10.minutes.from_now }

    it { is_expected.to allow_value(allowed_future).for(:expires_at) }
  end
end
