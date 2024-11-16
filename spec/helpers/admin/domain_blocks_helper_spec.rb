# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DomainBlocksHelper do
  describe '#domain_block_policies' do
    subject { helper.domain_block_policies(domain_block) }

    context 'with a suspend domain block' do
      let(:domain_block) { Fabricate.build :domain_block, severity: :suspend }

      it { is_expected.to eq('Suspend') }
    end

    context 'with a multi policy domain block' do
      let(:domain_block) { Fabricate.build :domain_block, severity: :silence, reject_media: true, reject_reports: true }

      it { is_expected.to eq('Limit · Reject media · Reject reports') }
    end
  end
end
