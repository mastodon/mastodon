# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ContentPoliciesHelper do
  describe '#policy_list' do
    subject { helper.policy_list(domain_block) }

    context 'when severity is suspend' do
      let(:domain_block) { Fabricate.build :domain_block, severity: :suspend }

      it { is_expected.to eq('Suspend') }
    end

    context 'when severity is silence' do
      let(:domain_block) { Fabricate.build :domain_block, severity: :silence, reject_reports: true }

      it { is_expected.to eq('Limit · Reject reports') }
    end
  end
end
