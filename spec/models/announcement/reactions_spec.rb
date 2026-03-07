# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Announcement::Reactions do
  subject { Fabricate.build :announcement }

  describe 'Associations' do
    it { is_expected.to have_many(:announcement_reactions).dependent(:destroy) }
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
end
