# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/domains'

describe Mastodon::CLI::Domains do
  it_behaves_like 'A CLI Sub-Command'

  describe 'purge' do
    before do
      Fabricate(:account, domain: 'example.com')
    end

    context 'with dry_run flag' do
      it 'runs without making changes' do
        expect { described_class.new.invoke(:purge, ['example.com'], { dry_run: true }) }.to output(
          a_string_including('(DRY RUN)')
        ).to_stdout
      end
    end
  end
end
