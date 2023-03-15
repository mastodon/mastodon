# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/federation'

describe Mastodon::CLI::Federation do
  it_behaves_like 'A CLI Sub-Command'

  describe 'self_destruct' do
    before do
      allow_any_instance_of(Thor::Shell::Basic).to receive(:ask).and_return Rails.configuration.x.local_domain
    end

    context 'with dry_run flag' do
      it 'runs without making changes' do
        expect { described_class.new.invoke(:self_destruct, [], { dry_run: true }) }.to output(
          a_string_including('has not federated')
        ).to_stdout
      end
    end
  end
end
