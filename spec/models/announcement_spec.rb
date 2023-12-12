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

  describe '#publish!' do
    it 'publishes an unpublished record' do
      announcement = Fabricate(:announcement, published: false, scheduled_at: 10.days.from_now)

      announcement.publish!

      expect(announcement).to be_published
      expect(announcement.published_at).to_not be_nil
      expect(announcement.scheduled_at).to be_nil
    end
  end

  describe '#unpublish!' do
    it 'unpublishes a published record' do
      announcement = Fabricate(:announcement, published: true)

      announcement.unpublish!

      expect(announcement).to_not be_published
      expect(announcement.scheduled_at).to be_nil
    end
  end

  describe '#time_range?' do
    it 'returns false when starts_at and ends_at are missing' do
      record = Fabricate.build(:announcement, starts_at: nil, ends_at: nil)

      expect(record.time_range?).to be(false)
    end

    it 'returns false when starts_at is present and ends_at is missing' do
      record = Fabricate.build(:announcement, starts_at: 5.days.from_now, ends_at: nil)

      expect(record.time_range?).to be(false)
    end

    it 'returns false when starts_at is missing and ends_at is present' do
      record = Fabricate.build(:announcement, starts_at: nil, ends_at: 5.days.from_now)

      expect(record.time_range?).to be(false)
    end

    it 'returns true when starts_at and ends_at are present' do
      record = Fabricate.build(:announcement, starts_at: 5.days.from_now, ends_at: 10.days.from_now)

      expect(record.time_range?).to be(true)
    end
  end

  describe '#reactions' do
    context 'with announcement_reactions present' do
      let!(:account) { Fabricate(:account) }
      let!(:announcement) { Fabricate(:announcement) }
      let!(:announcement_reaction) { Fabricate(:announcement_reaction, announcement: announcement, created_at: 10.days.ago) }
      let!(:announcement_reaction_account) { Fabricate(:announcement_reaction, announcement: announcement, created_at: 5.days.ago, account: account) }

      before do
        Fabricate(:announcement_reaction)
      end

      it 'returns the announcement reactions for the announcement' do
        results = announcement.reactions

        expect(results.first.name).to eq(announcement_reaction.name)
        expect(results.last.name).to eq(announcement_reaction_account.name)
      end

      it 'returns the announcement reactions for the announcement limited to account' do
        results = announcement.reactions(account)

        expect(results.first.name).to eq(announcement_reaction.name)
      end
    end
  end
end
