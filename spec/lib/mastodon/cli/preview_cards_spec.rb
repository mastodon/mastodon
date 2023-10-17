# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/preview_cards'

describe Mastodon::CLI::PreviewCards do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#remove' do
    context 'with relevant preview cards' do
      before do
        Fabricate(:preview_card, updated_at: 10.years.ago, type: :link)
        Fabricate(:preview_card, updated_at: 10.months.ago, type: :photo)
        Fabricate(:preview_card, updated_at: 10.days.ago, type: :photo)
      end

      context 'with no arguments' do
        it 'deletes thumbnails for local preview cards' do
          expect { cli.invoke(:remove) }.to output(
            a_string_including('Removed 2 preview cards')
              .and(a_string_including('approx. 119 KB'))
          ).to_stdout
        end
      end

      context 'with the --link option' do
        let(:options) { { link: true } }

        it 'deletes thumbnails for local preview cards' do
          expect { cli.invoke(:remove, [], options) }.to output(
            a_string_including('Removed 1 link-type preview cards')
              .and(a_string_including('approx. 59.6 KB'))
          ).to_stdout
        end
      end

      context 'with the --days option' do
        let(:options) { { days: 365 } }

        it 'deletes thumbnails for local preview cards' do
          expect { cli.invoke(:remove, [], options) }.to output(
            a_string_including('Removed 1 preview cards')
              .and(a_string_including('approx. 59.6 KB'))
          ).to_stdout
        end
      end
    end
  end
end
