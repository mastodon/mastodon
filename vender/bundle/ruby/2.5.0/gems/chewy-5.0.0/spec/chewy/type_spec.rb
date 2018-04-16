require 'spec_helper'

describe Chewy::Type do
  describe '.derivable_name' do
    specify { expect { Class.new(Chewy::Type).derivable_name }.to raise_error NotImplementedError }

    specify do
      index = Class.new(Chewy::Index) { define_type :city }
      expect(index::City.derivable_name).to be_nil
    end

    specify do
      stub_index(:places) { define_type :city }
      expect(PlacesIndex::City.derivable_name).to eq('places#city')
    end

    specify do
      stub_index('namespace/places') { define_type :city }
      expect(Namespace::PlacesIndex::City.derivable_name).to eq('namespace/places#city')
    end
  end

  describe '.types' do
    subject { Class.new(Chewy::Type) }
    specify { expect(subject.types).to eq([subject]) }
  end

  describe '.scopes' do
    before do
      stub_index(:places) do
        def self.by_id; end

        define_type :city do
          def self.by_rating; end

          def self.by_name; end
        end
      end
    end

    specify { expect(described_class.scopes).to eq([]) }
    specify { expect(PlacesIndex::City.scopes).to match_array(%i[by_rating by_name]) }
    specify { expect { PlacesIndex::City.non_existing_method_call }.to raise_error(NoMethodError) }

    specify { expect(PlacesIndex::City._default_import_options).to eq({}) }
    specify { expect { PlacesIndex::City.default_import_options(invalid_option: 'Yeah!') }.to raise_error(ArgumentError) }

    context 'default_import_options is set' do
      let(:converter) { -> {} }
      before { PlacesIndex::City.default_import_options(batch_size: 500, raw_import: converter) }

      specify { expect(PlacesIndex::City._default_import_options).to eq(batch_size: 500, raw_import: converter) }
    end
  end
end
