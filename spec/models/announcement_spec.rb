# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Announcement do
  describe 'Scopes' do
    context 'with published and unpublished records' do
      let!(:published) { Fabricate(:announcement, published: true) }
      let!(:unpublished) { Fabricate(:announcement, published: false, scheduled_at: 10.days.from_now) }

      describe '#unpublished' do
        it 'returns records with published false' do
          results = described_class.unpublished

          expect(results).to eq([unpublished])
        end
      end

      describe '#published' do
        it 'returns records with published true' do
          results = described_class.published

          expect(results).to eq([published])
        end
      end
    end

    context 'with timestamped announcements' do
      let!(:adam_announcement) { Fabricate(:announcement, starts_at: 100.days.ago, scheduled_at: 10.days.ago, published_at: 10.days.ago, ends_at: 5.days.from_now) }
      let!(:brenda_announcement) { Fabricate(:announcement, starts_at: 10.days.ago, scheduled_at: 100.days.ago, published_at: 10.days.ago, ends_at: 5.days.from_now) }
      let!(:clara_announcement) { Fabricate(:announcement, starts_at: 10.days.ago, scheduled_at: 10.days.ago, published_at: 100.days.ago, ends_at: 5.days.from_now) }
      let!(:darnelle_announcement) { Fabricate(:announcement, starts_at: 10.days.ago, scheduled_at: 10.days.ago, published_at: 10.days.ago, ends_at: 5.days.from_now, created_at: 100.days.ago) }

      describe '#chronological' do
        it 'orders the records correctly' do
          results = described_class.chronological

          expect(results).to eq(
            [
              adam_announcement,
              brenda_announcement,
              clara_announcement,
              darnelle_announcement,
            ]
          )
        end
      end

      describe '#reverse_chronological' do
        it 'orders the records correctly' do
          results = described_class.reverse_chronological

          expect(results).to eq(
            [
              darnelle_announcement,
              clara_announcement,
              brenda_announcement,
              adam_announcement,
            ]
          )
        end
      end
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:text) }

    describe 'ends_at' do
      context 'when starts_at is present' do
        subject { Fabricate.build :announcement, starts_at: 1.day.ago }

        it { is_expected.to validate_presence_of(:ends_at) }
      end

      context 'when starts_at is missing' do
        subject { Fabricate.build :announcement, starts_at: nil }

        it { is_expected.to_not validate_presence_of(:ends_at) }
      end
    end

    describe 'starts_at' do
      context 'when ends_at is present' do
        subject { Fabricate.build :announcement, ends_at: 1.day.ago }

        it { is_expected.to validate_presence_of(:starts_at) }
      end

      context 'when ends_at is missing' do
        subject { Fabricate.build :announcement, ends_at: nil }

        it { is_expected.to_not validate_presence_of(:starts_at) }
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

  describe '#reactions' do
    context 'with announcement_reactions present' do
      let(:account_reaction_emoji) { Fabricate :custom_emoji }
      let(:other_reaction_emoji) { Fabricate :custom_emoji }
      let!(:account) { Fabricate(:account) }
      let!(:announcement) { Fabricate(:announcement) }

      before do
        Fabricate(:announcement_reaction, announcement: announcement, created_at: 10.days.ago, name: other_reaction_emoji.shortcode)
        Fabricate(:announcement_reaction, announcement: announcement, created_at: 5.days.ago, account: account, name: account_reaction_emoji.shortcode)
        Fabricate(:announcement_reaction) # For some other announcement
      end

      it 'returns the announcement reactions for the announcement' do
        results = announcement.reactions

        expect(results).to have_attributes(
          size: eq(2),
          first: have_attributes(name: other_reaction_emoji.shortcode, me: false),
          last: have_attributes(name: account_reaction_emoji.shortcode, me: false)
        )
      end

      it 'returns the announcement reactions for the announcement with `me` set correctly' do
        results = announcement.reactions(account)

        expect(results).to have_attributes(
          size: eq(2),
          first: have_attributes(name: other_reaction_emoji.shortcode, me: false),
          last: have_attributes(name: account_reaction_emoji.shortcode, me: true)
        )
      end
    end
  end

  describe '#statuses' do
    let(:announcement) { Fabricate(:announcement, status_ids: status_ids) }

    context 'with empty status_ids' do
      let(:status_ids) { nil }

      it 'returns empty array' do
        results = announcement.statuses

        expect(results).to eq([])
      end
    end

    context 'with relevant status_ids' do
      let(:status) { Fabricate(:status, visibility: :public) }
      let(:direct_status) { Fabricate(:status, visibility: :direct) }
      let(:status_ids) { [status.id, direct_status.id] }

      it 'returns public and unlisted statuses' do
        results = announcement.statuses

        expect(results).to include(status)
        expect(results).to_not include(direct_status)
      end
    end
  end
end
