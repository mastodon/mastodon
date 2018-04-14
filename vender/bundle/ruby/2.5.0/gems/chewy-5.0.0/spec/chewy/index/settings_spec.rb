require 'spec_helper'

describe Chewy::Index::Settings do
  describe '#to_hash' do
    before { allow(Chewy).to receive_messages(config: Chewy::Config.send(:new)) }
    before { allow(Chewy).to receive_messages(repository: Chewy::Repository.send(:new)) }

    specify { expect(described_class.new.to_hash).to eq({}) }
    specify { expect(described_class.new(number_of_nodes: 3).to_hash).to eq(settings: {number_of_nodes: 3}) }
    specify do
      expect(described_class.new(number_of_nodes: 3, analysis: {}).to_hash)
        .to eq(settings: {number_of_nodes: 3, analysis: {}})
    end
    specify do
      expect(described_class.new(number_of_nodes: 3, analysis: {filter: {filter1: {}}}).to_hash)
        .to eq(settings: {number_of_nodes: 3, analysis: {filter: {filter1: {}}}})
    end
    specify do
      expect(described_class.new(number_of_nodes: 3, analysis: {analyzer: {analyzer1: {}}}).to_hash)
        .to eq(settings: {number_of_nodes: 3, analysis: {analyzer: {analyzer1: {}}}})
    end
    specify do
      expect(described_class.new(number_of_nodes: 3, analysis: {
        analyzer: {analyzer1: {tokenizer: 'tokenizer1', filter: %w[filter1 filter2]}}
      }).to_hash)
        .to eq(settings: {number_of_nodes: 3, analysis: {
          analyzer: {analyzer1: {tokenizer: 'tokenizer1', filter: %w[filter1 filter2]}}
        }})
    end
    specify do
      expect(described_class.new(number_of_nodes: 3, analysis: {analyzer: ['analyzer1']}).to_hash)
        .to eq(settings: {number_of_nodes: 3, analysis: {}})
    end
    specify do
      expect(described_class.new(number_of_nodes: 3, analysis: {analyzer: {analyzer1: {}}, normalizer: {}}).to_hash)
        .to eq(settings: {number_of_nodes: 3, analysis: {analyzer: {analyzer1: {}}, normalizer: {}}})
    end
    specify do
      expect(described_class.new(number_of_nodes: 3, analysis: {analyzer: ['analyzer1'], normalizer: {}}).to_hash)
        .to eq(settings: {number_of_nodes: 3, analysis: {normalizer: {}}})
    end

    specify do
      stub_const('Synonyms', Class.new do
        def self.synonyms
          ['kaftan => dress']
        end
      end)
      expect(
        described_class.new do
          {
            analysis: {filter: {synonym: {type: 'synonym', synonyms: Synonyms.synonyms}}}
          }
        end.to_hash
      ).to eq(settings: {
        analysis: {filter: {
          synonym: {
            type: 'synonym', synonyms: ['kaftan => dress']
          }
        }}
      })
    end

    context do
      before { Chewy.tokenizer :tokenizer1, options: 42 }

      specify do
        expect(described_class.new(number_of_nodes: 3, analysis: {
          analyzer: {analyzer1: {tokenizer: 'tokenizer1', filter: %w[filter1 filter2]}}
        }).to_hash)
          .to eq(settings: {number_of_nodes: 3, analysis: {
            analyzer: {analyzer1: {tokenizer: 'tokenizer1', filter: %w[filter1 filter2]}},
            tokenizer: {tokenizer1: {options: 42}}
          }})
      end
    end

    context do
      before do
        Chewy.filter :filter2, options: 42
        Chewy.filter :filter3, options: 43
        Chewy.filter :filter5, options: 44
      end

      specify do
        expect(described_class.new(number_of_nodes: 3, analysis: {
          analyzer: {analyzer1: {tokenizer: 'tokenizer1', filter: %w[filter1 filter2]}},
          filter: ['filter3', {filter4: {options: 45}}]
        }).to_hash)
          .to eq(settings: {number_of_nodes: 3, analysis: {
            analyzer: {analyzer1: {tokenizer: 'tokenizer1', filter: %w[filter1 filter2]}},
            filter: {filter2: {options: 42}, filter3: {options: 43}, filter4: {options: 45}}
          }})
      end
    end

    context do
      before do
        Chewy.analyzer :analyzer1, options: 42, tokenizer: 'tokenizer1'
        Chewy.tokenizer :tokenizer1, options: 43
      end

      specify do
        expect(described_class.new(number_of_nodes: 3, analysis: {
          analyzer: ['analyzer1', {analyzer2: {options: 44}}]
        }).to_hash)
          .to eq(settings: {number_of_nodes: 3, analysis: {
            analyzer: {analyzer1: {options: 42, tokenizer: 'tokenizer1'}, analyzer2: {options: 44}},
            tokenizer: {tokenizer1: {options: 43}}
          }})
      end
    end

    context ':index' do
      specify do
        expect(described_class.new(index: {number_of_shards: 3}).to_hash)
          .to eq(settings: {index: {number_of_shards: 3}})
      end

      context do
        before { allow(Chewy).to receive_messages(configuration: {index: {number_of_shards: 7, number_of_replicas: 2}}) }

        specify do
          expect(described_class.new.to_hash)
            .to eq(settings: {index: {number_of_shards: 7, number_of_replicas: 2}})
        end
        specify do
          expect(described_class.new(index: {number_of_shards: 3}).to_hash)
            .to eq(settings: {index: {number_of_shards: 3, number_of_replicas: 2}})
        end
      end
    end
  end
end
