require 'spec_helper'

describe Chewy::Config do
  subject { described_class.send(:new) }

  its(:logger) { should be_nil }
  its(:transport_logger) { should be_nil }
  its(:transport_logger) { should be_nil }
  its(:query_mode) { should == :must }
  its(:filter_mode) { should == :and }
  its(:post_filter_mode) { should be_nil }
  its(:root_strategy) { should == :base }
  its(:request_strategy) { should == :atomic }
  its(:use_after_commit_callbacks) { should == true }
  its(:indices_path) { should == 'app/chewy' }
  its(:reset_disable_refresh_interval) { should == false }
  its(:reset_no_replicas) { should == false }
  its(:disable_refresh_async) { should == false }
  its(:search_class) { should be < Chewy::Search::Request }

  describe '#transport_logger=' do
    let(:logger) { Logger.new('/dev/null') }
    after { subject.transport_logger = nil }

    specify do
      expect { subject.transport_logger = logger }
        .to change { Chewy.client.transport.logger }.to(logger)
    end
    specify do
      expect { subject.transport_logger = logger }
        .to change { subject.transport_logger }.to(logger)
    end
    specify do
      expect { subject.transport_logger = logger }
        .to change { subject.configuration[:logger] }.from(nil).to(logger)
    end
  end

  describe '#transport_tracer=' do
    let(:tracer) { Logger.new('/dev/null') }
    after { subject.transport_tracer = nil }

    specify do
      expect { subject.transport_tracer = tracer }
        .to change { Chewy.client.transport.tracer }.to(tracer)
    end
    specify do
      expect { subject.transport_tracer = tracer }
        .to change { subject.transport_tracer }.to(tracer)
    end
    specify do
      expect { subject.transport_tracer = tracer }
        .to change { subject.configuration[:tracer] }.from(nil).to(tracer)
    end
  end

  describe '#search_class=' do
    specify do
      expect { subject.search_class = Chewy::Query }
        .to change { subject.search_class }
        .from(be < Chewy::Search::Request)
        .to(be < Chewy::Query)
    end

    context do
      before { hide_const('Kaminari') }

      specify do
        expect(subject.search_class.included_modules)
          .to include(Chewy::Search::Pagination::WillPaginate)
      end
    end
  end

  describe '#search_class' do
    context 'nothing is defined' do
      before do
        hide_const('Kaminari')
        hide_const('WillPaginate')
      end

      specify do
        expect(subject.search_class.included_modules)
          .not_to include(Chewy::Search::Pagination::Kaminari)
      end

      specify do
        expect(subject.search_class.included_modules)
          .not_to include(Chewy::Search::Pagination::WillPaginate)
      end
    end

    context 'kaminari' do
      before { hide_const('WillPaginate') }

      specify do
        expect(subject.search_class.included_modules)
          .to include(Chewy::Search::Pagination::Kaminari)
      end

      specify do
        expect(subject.search_class.included_modules)
          .not_to include(Chewy::Search::Pagination::WillPaginate)
      end
    end

    context 'will_paginate' do
      before { hide_const('Kaminari') }

      specify do
        expect(subject.search_class.included_modules)
          .not_to include(Chewy::Search::Pagination::Kaminari)
      end

      specify do
        expect(subject.search_class.included_modules)
          .to include(Chewy::Search::Pagination::WillPaginate)
      end
    end

    context 'both are defined' do
      specify do
        expect(subject.search_class.included_modules)
          .to include(Chewy::Search::Pagination::Kaminari)
      end

      specify do
        expect(subject.search_class.included_modules)
          .not_to include(Chewy::Search::Pagination::WillPaginate)
      end
    end
  end

  describe '#configuration' do
    before { subject.settings = {indices_path: 'app/custom_indices_path'} }

    specify do
      expect(subject.configuration).to include(indices_path: 'app/custom_indices_path')
    end

    context 'when Rails::VERSION constant is defined' do
      it 'looks for configuration in "config/chewy.yml"' do
        module Rails
          VERSION = '5.1.0'.freeze

          def self.root
            Pathname.new(__dir__)
          end
        end

        expect(File).to receive(:exist?)
          .with(Pathname.new(__dir__).join('config', 'chewy.yml'))
        subject.configuration
      end
    end
  end
end
