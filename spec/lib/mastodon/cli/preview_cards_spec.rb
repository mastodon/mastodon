# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/preview_cards'

RSpec.describe Mastodon::CLI::PreviewCards do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#remove' do
    let(:action) { :remove }

    context 'with relevant preview cards' do
      before do
        Fabricate(:preview_card, updated_at: 10.years.ago, type: :link)
        Fabricate(:preview_card, updated_at: 10.months.ago, type: :photo)
        Fabricate(:preview_card, updated_at: 10.days.ago, type: :photo)
      end

      context 'with no arguments' do
        it 'deletes thumbnails for local preview cards' do
          expect { subject }
            .to output_results(
              'Removed 2 preview cards',
              'approx. 119 KB'
            )
        end
      end

      context 'with the --link option' do
        let(:options) { { link: true } }

        it 'deletes thumbnails for local preview cards' do
          expect { subject }
            .to output_results(
              'Removed 1 link-type preview cards',
              'approx. 59.6 KB'
            )
        end
      end

      context 'with the --days option' do
        let(:options) { { days: 365 } }

        it 'deletes thumbnails for local preview cards' do
          expect { subject }
            .to output_results(
              'Removed 1 preview cards',
              'approx. 59.6 KB'
            )
        end
      end
    end
  end
end
