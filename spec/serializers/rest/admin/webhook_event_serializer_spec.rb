# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::WebhookEventSerializer do
  describe '.serializer_for' do
    subject { described_class.serializer_for(model, {}) }

    context 'with an Account model' do
      let(:model) { Account.new }

      it { is_expected.to eq(REST::Admin::AccountSerializer) }
    end

    context 'with a Report model' do
      let(:model) { Report.new }

      it { is_expected.to eq(REST::Admin::ReportSerializer) }
    end

    context 'with a Status model' do
      let(:model) { Status.new }

      it { is_expected.to eq(REST::StatusSerializer) }
    end

    context 'with an Array' do
      let(:model) { [] }

      it { is_expected.to eq(ActiveModel::Serializer::CollectionSerializer) }
    end
  end
end
