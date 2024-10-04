# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/search'

RSpec.describe Mastodon::CLI::Search do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#deploy' do
    let(:action) { :deploy }

    context 'with concurrency out of range' do
      let(:options) { { concurrency: -100 } }

      it 'Exits with error message' do
        expect { subject }
          .to raise_error(Thor::Error, /this concurrency setting/)
      end
    end

    context 'with batch size out of range' do
      let(:options) { { batch_size: -100_000 } }

      it 'Exits with error message' do
        expect { subject }
          .to raise_error(Thor::Error, /this batch_size setting/)
      end
    end

    context 'when server communication raises an error' do
      let(:options) { { reset_chewy: true } }

      before { allow(Chewy::Stash::Specification).to receive(:reset!).and_raise(Elasticsearch::Transport::Transport::Errors::InternalServerError) }

      it 'Exits with error message' do
        expect { subject }
          .to raise_error(Thor::Error, /issue connecting to the search/)
      end
    end

    context 'without options' do
      before { stub_search_indexes }

      let(:indexed_count) { 1 }
      let(:deleted_count) { 2 }

      it 'reports about storage size' do
        expect { subject }
          .to output_results(
            "Indexed #{described_class::INDICES.size * indexed_count} records",
            "de-indexed #{described_class::INDICES.size * deleted_count}"
          )
      end
    end

    def stub_search_indexes
      described_class::INDICES.each do |index|
        allow(index)
          .to receive_messages(
            specification: instance_double(Chewy::Index::Specification, changed?: true, lock!: nil),
            purge: nil
          )

        importer_double = importer_double_for(index)
        allow(importer_double).to receive(:on_progress).and_yield([indexed_count, deleted_count])
        allow("Importer::#{index}Importer".constantize)
          .to receive(:new)
          .and_return(importer_double)
      end
    end

    def importer_double_for(index)
      instance_double(
        "Importer::#{index}Importer".constantize,
        clean_up!: nil,
        estimate!: 100,
        import!: nil,
        on_failure: nil,
        # on_progress: nil,
        optimize_for_import!: nil,
        optimize_for_search!: nil
      )
    end
  end
end
