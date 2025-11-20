# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  describe 'Validations' do
    subject { Fabricate.build :collection }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:description) }

    context 'when collection is remote' do
      subject { Fabricate.build :collection, local: false }

      it { is_expected.to validate_presence_of(:uri) }

      it { is_expected.to validate_presence_of(:remote_items) }
    end

    context 'when using a hashtag as category' do
      subject { Fabricate.build(:collection, tag:) }

      context 'when hashtag is usable' do
        let(:tag) { Fabricate.build(:tag) }

        it { is_expected.to be_valid }
      end

      context 'when hashtag is not usable' do
        let(:tag) { Fabricate.build(:tag, usable: false) }

        it { is_expected.to_not be_valid }
      end
    end
  end
end
