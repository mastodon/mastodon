# frozen_string_literal: true

require 'rails_helper'

describe PrivacyPolicy do
  describe '.current' do
    context 'with the default values' do
      it 'has the privacy text' do
        policy = described_class.current

        expect(policy.text).to eq(described_class::DEFAULT_PRIVACY_POLICY)
      end
    end

    context 'with a custom setting value' do
      before do
        terms_setting = instance_double(Setting, value: 'Terms text', updated_at: 10.days.ago)
        allow(Setting).to receive(:find_by).with(var: 'site_terms').and_return(terms_setting)
      end

      it 'has the privacy text' do
        policy = described_class.current

        expect(policy.text).to eq('Terms text')
      end
    end
  end
end
