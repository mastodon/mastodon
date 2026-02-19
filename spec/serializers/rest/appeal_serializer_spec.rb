# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::AppealSerializer do
  subject { serialized_record_json(record, described_class) }

  describe 'state' do
    context 'when appeal is approved' do
      let(:record) { Fabricate.build :appeal, approved_at: 2.days.ago }

      it { is_expected.to include('state' => 'approved') }
    end

    context 'when appeal is rejected' do
      let(:record) { Fabricate.build :appeal, rejected_at: 2.days.ago }

      it { is_expected.to include('state' => 'rejected') }
    end

    context 'when appeal is not approved or rejected' do
      let(:record) { Fabricate.build :appeal, approved_at: nil, rejected_at: nil }

      it { is_expected.to include('state' => 'pending') }
    end
  end
end
