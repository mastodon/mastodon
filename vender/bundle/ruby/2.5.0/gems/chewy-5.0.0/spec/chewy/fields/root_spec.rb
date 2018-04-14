require 'spec_helper'

describe Chewy::Fields::Root do
  subject(:field) { described_class.new('product') }

  describe '#dynamic_template' do
    specify do
      field.dynamic_template 'hello', type: 'keyword'
      field.dynamic_template 'hello*', :integer
      field.dynamic_template 'hello.*'
      field.dynamic_template(/hello/)
      field.dynamic_template(/hello.*/)
      field.dynamic_template template_42: {mapping: {}, match: ''}
      field.dynamic_template(/hello\..*/)

      expect(field.mappings_hash).to eq(product: {dynamic_templates: [
        {template_1: {mapping: {type: 'keyword'}, match: 'hello'}},
        {template_2: {mapping: {}, match_mapping_type: 'integer', match: 'hello*'}},
        {template_3: {mapping: {}, path_match: 'hello.*'}},
        {template_4: {mapping: {}, match: 'hello', match_pattern: 'regexp'}},
        {template_5: {mapping: {}, match: 'hello.*', match_pattern: 'regexp'}},
        {template_42: {mapping: {}, match: ''}},
        {template_7: {mapping: {}, path_match: 'hello\..*', match_pattern: 'regexp'}}
      ]})
    end

    context do
      subject(:field) do
        described_class.new('product', dynamic_templates: [
          {template_42: {mapping: {}, match: ''}}
        ])
      end

      specify do
        field.dynamic_template 'hello', type: 'keyword'
        expect(field.mappings_hash).to eq(product: {dynamic_templates: [
          {template_42: {mapping: {}, match: ''}},
          {template_1: {mapping: {type: 'keyword'}, match: 'hello'}}
        ]})
      end
    end
  end

  describe '#compose' do
    context 'empty children', :orm do
      before do
        stub_model(:city)
        stub_index(:places) do
          define_type City
        end
      end

      let(:city) { City.new(name: 'London', rating: 100) }

      specify do
        expect(PlacesIndex::City.root.compose(city))
          .to match(hash_including('name' => 'London', 'rating' => 100))
      end
      specify do
        expect(PlacesIndex::City.root.compose(city, fields: %i[name borogoves]))
          .to eq('name' => 'London')
      end
    end

    context 'has children' do
      before do
        stub_index(:places) do
          define_type :city do
            field :name, :rating
          end
        end
      end

      let(:city) { double(name: 'London', rating: 100) }

      specify do
        expect(PlacesIndex::City.root.compose(city))
          .to eq('name' => 'London', 'rating' => 100)
      end
      specify do
        expect(PlacesIndex::City.root.compose(city, fields: %i[name borogoves]))
          .to eq('name' => 'London')
      end
    end

    context 'root value provided' do
      before do
        stub_index(:places) do
          define_type :city do
            root value: ->(o) { {name: o.name + 'Modified', rating: o.rating.next} }
          end
        end
      end

      let(:city) { double(name: 'London', rating: 100) }

      specify do
        expect(PlacesIndex::City.root.compose(city))
          .to eq('name' => 'LondonModified', 'rating' => 101)
      end

      specify do
        expect(PlacesIndex::City.root.compose(city, fields: %i[name borogoves]))
          .to eq('name' => 'LondonModified')
      end
    end

    context 'complex evaluations' do
      before do
        stub_index(:places) do
          define_type :city do
            root value: ->(o) { {name: o.name + 'Modified', rating: o.rating.next} } do
              field :name, value: ->(o) { o[:name] + 'Modified' }
              field :rating
            end
          end
        end
      end

      let(:city) { double(name: 'London', rating: 100) }

      specify do
        expect(PlacesIndex::City.root.compose(city))
          .to eq('name' => 'LondonModifiedModified', 'rating' => 101)
      end

      specify do
        expect(PlacesIndex::City.root.compose(city, fields: %i[name borogoves]))
          .to eq('name' => 'LondonModifiedModified')
      end
    end
  end

  describe '#child_hash' do
    before do
      stub_index(:places) do
        define_type :city do
          field :name, :rating
        end
      end
    end

    specify do
      expect(PlacesIndex::City.root.child_hash).to match(
        name: an_instance_of(Chewy::Fields::Base).and(have_attributes(name: :name)),
        rating: an_instance_of(Chewy::Fields::Base).and(have_attributes(name: :rating))
      )
    end
  end
end
