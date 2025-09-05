# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollExpirationValidator, type: :model do
  subject { record_class.new }

  let(:record_class) do
    Class.new do
      include ActiveModel::Validations
      include ActiveModel::Attributes

      def self.name = 'Record'

      attribute :expires_at, :datetime

      validates_with PollExpirationValidator
    end
  end

  context 'when poll expires in far future' do
    it { is_expected.to_not allow_value(6.months.from_now).for(:expires_at).with_message(I18n.t('polls.errors.duration_too_long')) }
  end

  context 'when poll expires in far past' do
    it { is_expected.to_not allow_value(6.days.ago).for(:expires_at).with_message(I18n.t('polls.errors.duration_too_short')) }
  end

  context 'when poll expires in medium future' do
    it { is_expected.to allow_value(10.minutes.from_now).for(:expires_at) }
  end
end
