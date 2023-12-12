# frozen_string_literal: true

require 'rails_helper'

describe Announcement do
  describe 'Scopes' do
    context 'with published and unpublished records' do
      let!(:published) { Fabricate(:announcement, published: true) }
      let!(:unpublished) { Fabricate(:announcement, published: false, scheduled_at: 10.days.from_now) }

      describe 'unpublished' do
        it 'returns records with published false' do
          results = described_class.unpublished

          expect(results).to eq([unpublished])
        end
      end

      describe 'published' do
        it 'returns records with published true' do
          results = described_class.published

          expect(results).to eq([published])
        end
      end
    end
  end

  describe 'Validations' do
    describe 'text' do
      it 'validates presence of attribute' do
        record = Fabricate.build(:announcement, text: nil)

        expect(record).to_not be_valid
        expect(record.errors[:text]).to be_present
      end
    end

    describe 'ends_at' do
      it 'validates presence when starts_at is present' do
        record = Fabricate.build(:announcement, starts_at: 1.day.ago)

        expect(record).to_not be_valid
        expect(record.errors[:ends_at]).to be_present
      end

      it 'does not validate presence when starts_at is missing' do
        record = Fabricate.build(:announcement, starts_at: nil)

        expect(record).to be_valid
        expect(record.errors[:ends_at]).to_not be_present
      end
    end
  end
end
