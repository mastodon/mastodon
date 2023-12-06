# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/emoji'

describe Mastodon::CLI::Emoji do
  subject { cli.invoke(action, args, options) }

  let(:cli) { described_class.new }
  let(:args) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#purge' do
    let(:action) { :purge }

    context 'with existing custom emoji' do
      before { Fabricate(:custom_emoji) }

      it 'reports a successful purge' do
        expect { subject }
          .to output_results('OK')
      end
    end
  end

  describe '#import' do
    context 'with existing custom emoji' do
      let(:import_path) { Rails.root.join('spec', 'fixtures', 'files', 'elite-assets.tar.gz') }
      let(:action) { :import }
      let(:args) { [import_path] }

      it 'reports about imported emoji' do
        expect { subject }
          .to output_results('Imported 1')
          .and change(CustomEmoji, :count).by(1)
      end
    end
  end

  describe '#export' do
    context 'with existing custom emoji' do
      before { Fabricate(:custom_emoji) }
      after { File.delete(export_path) }

      let(:export_path) { Rails.root.join('tmp', 'export.tar.gz') }
      let(:args) { [Rails.root.join('tmp')] }
      let(:action) { :export }

      it 'reports about exported emoji' do
        expect { subject }
          .to output_results('Exported 1')
          .and change { File.exist?(export_path) }.from(false).to(true)
      end
    end
  end

  def output_results(string)
    output(a_string_including(string)).to_stdout
  end
end
