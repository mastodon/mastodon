# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkImportRow do
  describe 'Associations' do
    it { is_expected.to belong_to(:bulk_import).required }
  end

  describe '#to_csv' do
    subject { described_class.new(bulk_import: Fabricate.build(:bulk_import, type:), data: {}).to_csv }

    context 'when bulk import is following type' do
      let(:type) { :following }

      it { is_expected.to be_a(Array) }
    end

    context 'when bulk import is blocking type' do
      let(:type) { :blocking }

      it { is_expected.to be_a(Array) }
    end

    context 'when bulk import is muting type' do
      let(:type) { :muting }

      it { is_expected.to be_a(Array) }
    end

    context 'when bulk import is domain_blocking type' do
      let(:type) { :domain_blocking }

      it { is_expected.to be_a(Array) }
    end

    context 'when bulk import is bookmarks type' do
      let(:type) { :bookmarks }

      it { is_expected.to be_a(Array) }
    end

    context 'when bulk import is lists type' do
      let(:type) { :lists }

      it { is_expected.to be_a(Array) }
    end
  end
end
